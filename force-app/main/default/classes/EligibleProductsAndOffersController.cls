/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : EligibleProductsAndOffersController
 * Author          : Ranjith Raja
 * Created Date    : Jan 7, 2026
 * Last Modified By: Ranjith Raja
 * Last Modified On: Jan 29, 2026
 * Description     : Controller for handling NBO Eligible Products & Offers functionality
 *
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jan 7, 2026  │ Ranjith Raja │ Initial version with enhanced UX
 *  Jan 7, 2026  │ Ranjith Raja │ Added proper error handling and logging
 *  Jan 21, 2026 │ Ranjith Raja │ Fixed case creation logic and queue assignment
 *  Jan 22, 2026 │ Ranjith Raja │ Integrated NBO API for real data fetching
 *  Jan 22, 2026 │ Ranjith Raja │ Added PATCH API for updating product decisions
 *  Jan 29, 2026 │ Ranjith Raja │ Added product/offer label APIs for better UX
 *  Jan 29, 2026 │ Ranjith Raja │ Enhanced label enrichment with robust error handling & logging
 *  Jan 29, 2026 │ Ranjith Raja │ Added comprehensive debug logging for full traceability
 *  Oct 6,  2026 │ Ranjith Raja │ FIXED: PATCH endpoint typo (`itemsss` → `items`)
 *               │              │ FIXED: Surface real API error message instead of
 *               │              │        "Script-thrown exception" from AuraHandledException
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
public with sharing class EligibleProductsAndOffersController {

    @TestVisible
    private static ApiConnection con = new ApiConnection();

    // API Constants
    private static final String NBO_BASE_PATH = '/api/v1/nbo/customers/';
    private static final String NBO_ITEMS_PATH = '/items';
    private static final String PRODUCT_CATALOGUE_PATH = '/api/v1/product-catalogue/nbo';
    private static final String OFFER_CATALOGUE_PATH = '/api/v1/product-catalogue/offers';
    private static final Integer TIMEOUT_MS = 12000;

    /**
     * Get NBO Eligible Products and Offers with enriched labels from catalogue APIs
     */
    @AuraEnabled(cacheable=true)
    public static NBOData getNBOData(Id accountId) {
        System.debug('🔵 [START] getNBOData called with accountId: ' + accountId);
        NBOData result = new NBOData();

        try {
            // Validate account ID
            if (accountId == null) {
                System.debug('❌ [ERROR] Account ID is null');
                throw new AuraHandledException('Account ID is required');
            }

            // Get customer ID from account
            System.debug('🔍 Fetching account details for Id: ' + accountId);
            Account account = getAccountDetails(accountId);
            if (account == null) {
                System.debug('❌ [ERROR] Account not found for Id: ' + accountId);
                throw new AuraHandledException('Account not found');
            }
            System.debug('✅ Account found: CIF=' + account.CIF__pc + ', x-canary=' + account.x_canary__pc + ', Region=' + account.Region_Flag__pc);

            if (String.isBlank(account.CIF__pc)) {
                System.debug('❌ [ERROR] CIF is blank for account: ' + accountId);
                throw new AuraHandledException('Customer ID not found for this account');
            }

            String xCanaryValue = String.isNotBlank(account.x_canary__pc) ? account.x_canary__pc : 'cbs';
            String regionName = String.isNotBlank(account.Region_Flag__pc) ? account.Region_Flag__pc : 'Bahrain';
            System.debug('📌 Using x-canary: ' + xCanaryValue + ', Region: ' + regionName);

            // Build API endpoint for NBO data
            String customerId = account.CIF__pc;
            String endpoint = NBO_BASE_PATH + EncodingUtil.urlEncode(customerId, 'UTF-8') + NBO_ITEMS_PATH;
            System.debug('🔗 NBO GET Endpoint: ' + endpoint);

            // Create HTTP request for NBO data
            HttpRequest req = con.createRequest('GET', endpoint, customerId, regionName);
            req.setHeader('x-canary', xCanaryValue);
            req.setTimeout(TIMEOUT_MS);

            System.debug('📤 NBO GET API Request: ' + endpoint);
            System.debug('📤 x-canary: ' + xCanaryValue);

            // Send request
            Http http = new Http();
            HttpResponse response = http.send(req);

            System.debug('📥 NBO GET API Response Status: ' + response.getStatusCode());
            System.debug('📥 Response Body: ' + response.getBody());

            // Process response
            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                System.debug('✅ NBO GET succeeded, parsing response...');
                result = parseNBOData(response.getBody());
                System.debug('✅ Parsed NBO data: Products=' + result.products.size() + ', Offers=' + result.offers.size());
            } else {
                String errorMsg = 'API returned status: ' + response.getStatusCode();
                if (String.isNotBlank(response.getBody())) {
                    errorMsg += ' - ' + response.getBody();
                }
                System.debug('❌ NBO GET failed: ' + errorMsg);
                throw new AuraHandledException('Failed to fetch NBO data: ' + errorMsg);
            }

            // Enrich with labels from catalogue APIs
            if (!result.products.isEmpty() || !result.offers.isEmpty()) {
                System.debug('🔁 Starting label enrichment...');
                enrichWithLabels(result, account);
                System.debug('✅ Enrichment completed.');
            } else {
                System.debug('⚠️ No products or offers to enrich.');
            }

            System.debug('📋 FINAL RESULT:');
            for (ProductWrapper p : result.products) {
                System.debug('   Product: id=' + p.id + ', name=' + p.name + ', score=' + p.confidenceScore);
            }
            for (OfferWrapper o : result.offers) {
                System.debug('   Offer: id=' + o.id + ', name=' + o.name + ', score=' + o.confidenceScore);
            }

            System.debug('🔵 [END] getNBOData returning result.');
            return result;

        } catch (AuraHandledException ae) {
            System.debug('❌ [AuraHandledException] ' + ae.getMessage());
            throw ae;
        } catch (Exception e) {
            System.debug('❌ [Exception] Error fetching NBO data: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Failed to fetch eligible products and offers: ' + e.getMessage());
        }
    }

    /**
     * Enrich NBO data with product and offer labels
     */
    private static void enrichWithLabels(NBOData data, Account account) {
        System.debug('🔵 [START] enrichWithLabels');
        try {
            String xCanaryValue = String.isNotBlank(account.x_canary__pc) ? account.x_canary__pc : 'cbs';
            String regionName = String.isNotBlank(account.Region_Flag__pc) ? account.Region_Flag__pc : 'Bahrain';

            // Fetch product labels
            if (!data.products.isEmpty()) {
                System.debug('📦 Enriching ' + data.products.size() + ' products...');
                List<String> productCodes = new List<String>();
                for (ProductWrapper p : data.products) {
                    if (String.isNotBlank(p.id)) {
                        productCodes.add(p.id);
                    }
                }
                System.debug('📋 Product codes to fetch labels: ' + productCodes);

                if (!productCodes.isEmpty()) {
                    Map<String, String> productNameMap = fetchProductLabels(productCodes, xCanaryValue, regionName);
                    System.debug('✅ Product label map size: ' + productNameMap.size());
                    for (ProductWrapper p : data.products) {
                        if (productNameMap.containsKey(p.id)) {
                            p.name = productNameMap.get(p.id);
                            System.debug('✅ Product label found for ' + p.id + ' → ' + p.name);
                        } else {
                            p.name = p.id;
                            System.debug('⚠️ No label found for product ' + p.id + ', using code as name');
                        }
                    }
                } else {
                    System.debug('⚠️ No valid product codes to look up.');
                }
            } else {
                System.debug('ℹ️ No products to enrich.');
            }

            // Fetch offer labels
            if (!data.offers.isEmpty()) {
                System.debug('📦 Enriching ' + data.offers.size() + ' offers...');
                List<String> offerIds = new List<String>();
                for (OfferWrapper o : data.offers) {
                    if (String.isNotBlank(o.id)) {
                        offerIds.add(o.id);
                    }
                }
                System.debug('📋 Offer IDs to fetch labels: ' + offerIds);

                if (!offerIds.isEmpty()) {
                    Map<String, String> offerNameMap = fetchOfferLabels(offerIds, xCanaryValue, regionName);
                    System.debug('✅ Offer label map size: ' + offerNameMap.size());
                    for (OfferWrapper o : data.offers) {
                        if (offerNameMap.containsKey(o.id)) {
                            o.name = offerNameMap.get(o.id);
                            System.debug('✅ Offer label found for ' + o.id + ' → ' + o.name);
                        } else {
                            o.name = o.id;
                            System.debug('⚠️ No label found for offer ' + o.id + ', using ID as name');
                        }
                    }
                } else {
                    System.debug('⚠️ No valid offer IDs to look up.');
                }
            } else {
                System.debug('ℹ️ No offers to enrich.');
            }

        } catch (Exception e) {
            System.debug('⚠️ Warning: Could not enrich labels: ' + e.getMessage());
            System.debug('⚠️ Stack trace: ' + e.getStackTraceString());
        }
        System.debug('🔵 [END] enrichWithLabels');
    }

    /**
     * Fetch product labels from product catalogue API
     */
    private static Map<String, String> fetchProductLabels(List<String> productCodes, String xCanary, String regionName) {
        System.debug('🔵 [START] fetchProductLabels with codes: ' + productCodes);
        Map<String, String> labelMap = new Map<String, String>();
        if (productCodes.isEmpty()) {
            System.debug('ℹ️ No product codes provided, returning empty map.');
            return labelMap;
        }

        try {
            List<Map<String, String>> productsList = new List<Map<String, String>>();
            for (String code : productCodes) {
                productsList.add(new Map<String, String>{'productCode' => code});
            }
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('products', productsList);
            String requestBodyJson = JSON.serialize(requestBody);

            System.debug('📤 Product Catalogue Request: ' + PRODUCT_CATALOGUE_PATH);
            System.debug('📤 Body: ' + requestBodyJson);

            HttpRequest req = con.createRequest('POST', PRODUCT_CATALOGUE_PATH, '6202914', regionName);
            req.setHeader('x-canary', 'nbo');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBodyJson);
            req.setTimeout(TIMEOUT_MS);

            System.debug('📤 Headers: x-canary=' + xCanary + ', Content-Type=application/json');

            Http http = new Http();
            HttpResponse response = http.send(req);

            System.debug('📥 Product Catalogue Response Status: ' + response.getStatusCode());
            System.debug('📥 Response Body: ' + response.getBody());

            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                System.debug('✅ Product catalogue API returned 200, parsing...');
                Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (parsed.containsKey('data') && parsed.get('data') != null) {
                    Map<String, Object> data = (Map<String, Object>) parsed.get('data');
                    List<Object> nboProducts = null;
                    if (data.containsKey('nboProducts')) {
                        nboProducts = (List<Object>) data.get('nboProducts');
                        System.debug('🔍 Found key "nboProducts"');
                    } else if (data.containsKey('products')) {
                        nboProducts = (List<Object>) data.get('products');
                        System.debug('🔍 Found key "products"');
                    } else {
                        System.debug('⚠️ No product list found in response. Available keys: ' + data.keySet());
                    }
                    if (nboProducts != null) {
                        System.debug('📋 Parsing ' + nboProducts.size() + ' products from catalogue...');
                        for (Object obj : nboProducts) {
                            Map<String, Object> product = (Map<String, Object>) obj;
                            String code = (String) product.get('productCode');
                            String name = (String) product.get('productName');
                            if (String.isNotBlank(code) && String.isNotBlank(name)) {
                                labelMap.put(code, name);
                                System.debug('   Mapped: ' + code + ' → ' + name);
                            } else {
                                System.debug('   ⚠️ Skipping product with missing code or name: ' + product);
                            }
                        }
                        System.debug('✅ Product labels fetched: ' + labelMap.size());
                    }
                } else {
                    System.debug('⚠️ Response does not contain "data" key. Response: ' + response.getBody());
                }
            } else {
                System.debug('⚠️ Product catalogue API returned status ' + response.getStatusCode() + '. Body: ' + response.getBody());
            }

        } catch (Exception e) {
            System.debug('❌ Error fetching product labels: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
        }
        System.debug('🔵 [END] fetchProductLabels returning ' + labelMap.size() + ' labels.');
        return labelMap;
    }

    /**
     * Fetch offer labels from offer catalogue API
     */
    private static Map<String, String> fetchOfferLabels(List<String> offerIds, String xCanary, String regionName) {
        System.debug('🔵 [START] fetchOfferLabels with IDs: ' + offerIds);
        Map<String, String> labelMap = new Map<String, String>();
        if (offerIds.isEmpty()) {
            System.debug('ℹ️ No offer IDs provided, returning empty map.');
            return labelMap;
        }

        try {
            String offerIdsParam = String.join(offerIds, ',');
            String endpoint = OFFER_CATALOGUE_PATH + '?offerIds=' + offerIdsParam;
            System.debug('📤 Offer Catalogue Request: ' + endpoint);

            HttpRequest req = con.createRequest('GET', endpoint, '6202914', regionName);
            req.setHeader('x-canary', 'nbo');
            req.setTimeout(TIMEOUT_MS);

            System.debug('📤 Headers: x-canary=nbo');

            Http http = new Http();
            HttpResponse response = http.send(req);

            System.debug('📥 Offer Catalogue Response Status: ' + response.getStatusCode());
            System.debug('📥 Response Body: ' + response.getBody());

            if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                System.debug('✅ Offer catalogue API returned 200, parsing...');

                Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                List<Object> offersList = null;
                Map<String, Object> container = parsed;

                if (parsed.containsKey('data') && parsed.get('data') != null) {
                    container = (Map<String, Object>) parsed.get('data');
                }

                for (String key : container.keySet()) {
                    Object value = container.get(key);
                    if (value instanceof List<Object>) {
                        offersList = (List<Object>) value;
                        System.debug('🔍 Found offer list under key: ' + key);
                        break;
                    }
                }

                if (offersList == null) {
                    if (container.containsKey('nboOffers')) {
                        offersList = (List<Object>) container.get('nboOffers');
                    } else if (container.containsKey('offers')) {
                        offersList = (List<Object>) container.get('offers');
                    } else if (container.containsKey('offerList')) {
                        offersList = (List<Object>) container.get('offerList');
                    } else if (container.containsKey('items')) {
                        offersList = (List<Object>) container.get('items');
                    }
                }

                if (offersList != null) {
                    System.debug('📋 Parsing ' + offersList.size() + ' offers from catalogue...');
                    for (Object obj : offersList) {
                        Map<String, Object> offer = (Map<String, Object>) obj;

                        String id = (String) offer.get('offerId');
                        if (String.isBlank(id)) id = (String) offer.get('productCode');
                        if (String.isBlank(id)) id = (String) offer.get('id');

                        String name = (String) offer.get('offerTitle');
                        if (String.isBlank(name)) name = (String) offer.get('offerName');
                        if (String.isBlank(name)) name = (String) offer.get('productName');
                        if (String.isBlank(name)) name = (String) offer.get('name');

                        if (String.isNotBlank(id) && String.isNotBlank(name)) {
                            labelMap.put(id, name);
                            System.debug('   Mapped: ' + id + ' → ' + name);
                        } else {
                            System.debug('   ⚠️ Skipping offer with missing id or name: ' + offer);
                        }
                    }
                    System.debug('✅ Offer labels fetched: ' + labelMap.size());
                } else {
                    System.debug('⚠️ No offer list found in response. Available keys: ' + container.keySet());
                }
            } else {
                System.debug('⚠️ Offer catalogue API returned status ' + response.getStatusCode() + '. Body: ' + response.getBody());
            }

        } catch (Exception e) {
            System.debug('❌ Error fetching offer labels: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
        }

        System.debug('🔵 [END] fetchOfferLabels returning ' + labelMap.size() + ' labels.');
        return labelMap;
    }

    /**
     * Update product decisions using PATCH API
     * This handles both products AND offers
     */
    @AuraEnabled
    public static UpdateResult updateProductDecisions(Id accountId, List<SelectedItem> selectedItems) {
        System.debug('🔵 [START] updateProductDecisions called with accountId: ' + accountId);
        System.debug('🔵 selectedItems: ' + JSON.serialize(selectedItems));
        UpdateResult result = new UpdateResult();

        try {
            if (selectedItems == null || selectedItems.isEmpty()) {
                System.debug('⚠️ No items to update');
                result.success = false;
                result.message = 'No items to update';
                return result;
            }

            if (accountId == null) {
                System.debug('❌ Account ID is null');
                result.success = false;
                result.message = 'Account ID is required';
                return result;
            }

            Account account = getAccountDetails(accountId);
            if (account == null || String.isBlank(account.CIF__pc)) {
                System.debug('❌ Customer ID not found for account: ' + accountId);
                result.success = false;
                result.message = 'Customer ID not found for this account';
                return result;
            }
            System.debug('✅ Account found: CIF=' + account.CIF__pc);

            List<Map<String, Object>> productActions = new List<Map<String, Object>>();
            List<Map<String, Object>> offerActions = new List<Map<String, Object>>();

            for (SelectedItem item : selectedItems) {
                if (String.isBlank(item.id)) continue;

                Map<String, Object> action = new Map<String, Object>();

                if ('Product'.equalsIgnoreCase(item.itemType)) {
                    action.put('productCode', item.id);
                } else if ('Offer'.equalsIgnoreCase(item.itemType)) {
                    action.put('offerId', item.id);
                } else {
                    continue;
                }

                if ('yes'.equalsIgnoreCase(item.customerInterest)) {
                    action.put('decision', 'INTERESTED');
                } else if ('no'.equalsIgnoreCase(item.customerInterest)) {
                    action.put('decision', 'NOT_INTERESTED');
                } else {
                    continue;
                }

                if ('Product'.equalsIgnoreCase(item.itemType)) {
                    productActions.add(action);
                } else if ('Offer'.equalsIgnoreCase(item.itemType)) {
                    offerActions.add(action);
                }
            }

            if (productActions.isEmpty() && offerActions.isEmpty()) {
                System.debug('⚠️ No valid actions to update');
                result.success = false;
                result.message = 'No valid actions to update';
                return result;
            }

            Map<String, Object> requestBody = new Map<String, Object>();
            if (!productActions.isEmpty()) {
                requestBody.put('productActions', productActions);
            }
            if (!offerActions.isEmpty()) {
                requestBody.put('offerActions', offerActions);
            }
            String requestBodyJson = JSON.serialize(requestBody);

            System.debug('📤 NBO PATCH Request Body: ' + requestBodyJson);
            System.debug('📤 Product Actions: ' + productActions.size());
            System.debug('📤 Offer Actions: ' + offerActions.size());

            // ✅ FIX: callPatchAPI now returns null on success, or the real
            //         error message string on failure. This avoids the
            //         "Script-thrown exception" problem from AuraHandledException.
            String patchError = callPatchAPI(account, requestBodyJson);

            if (patchError == null) {
                result.success = true;
                Integer totalActions = productActions.size() + offerActions.size();
                result.message = 'Successfully updated ' + totalActions + ' item decision(s)';
                result.updatedCount = totalActions;
                System.debug('✅ Product decisions updated successfully');
            } else {
                result.success = false;
                result.message = 'Failed to update product decisions: ' + patchError;
                System.debug('❌ Product decisions update failed: ' + patchError);
            }

        } catch (Exception e) {
            System.debug('❌ Error updating product decisions: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
            result.success = false;
            result.message = 'Failed to update product decisions: ' + e.getMessage();
        }
        System.debug('🔵 [END] updateProductDecisions returning: ' + JSON.serialize(result));
        return result;
    }

    /**
     * Create cases for interested products and offers
     */
    @AuraEnabled
    public static CaseCreationResult createCases(Id accountId, List<SelectedItem> selectedItems) {
        System.debug('🔵 [START] createCases called with accountId: ' + accountId);
        System.debug('🔵 selectedItems: ' + JSON.serialize(selectedItems));
        CaseCreationResult result = new CaseCreationResult();

        try {
            if (selectedItems == null || selectedItems.isEmpty()) {
                System.debug('⚠️ No items selected for case creation');
                result.success = false;
                result.message = 'No items selected for case creation';
                return result;
            }

            if (accountId == null) {
                System.debug('❌ Account ID is null');
                result.success = false;
                result.message = 'Account ID is required for case creation';
                return result;
            }

            List<Case> casesToInsert = new List<Case>();

            Id recordTypeId = getCaseRecordTypeId();
            if (recordTypeId == null) {
                System.debug('❌ No Case Record Type found');
                result.success = false;
                result.message = 'No Case Record Type found';
                return result;
            }
            System.debug('✅ Case Record Type ID: ' + recordTypeId);

            Id nboQueueId = getNBOQueueId();
            if (nboQueueId == null) {
                nboQueueId = UserInfo.getUserId();
                System.debug('⚠️ Using current user as owner: ' + nboQueueId);
            } else {
                System.debug('✅ NBO Queue ID: ' + nboQueueId);
            }

            Integer caseCount = 0;
            for (SelectedItem item : selectedItems) {
                if (String.isBlank(item.name) || !'yes'.equalsIgnoreCase(item.customerInterest)) {
                    continue;
                }

                Case newCase = new Case();
                newCase.RecordTypeId = recordTypeId;
                newCase.Subject = 'NBO Eligible Products & Offers';
                newCase.AccountId = accountId;
                newCase.Description = item.name + ' (' + item.itemType + ')';
                newCase.Type = 'Sales';
                newCase.Sub_Type__c = 'NBO Eligible Products & Offers';
                newCase.Origin = 'NBO';
                newCase.Case_Nature__c = 'Proactive Approach';
                newCase.OwnerId = nboQueueId;
                newCase.Status = 'In Progress';
                newCase.Sub_Status__c = 'In-Progress';

                casesToInsert.add(newCase);
                caseCount++;
            }

            if (!casesToInsert.isEmpty()) {
                System.debug('📝 Inserting ' + casesToInsert.size() + ' cases...');
                insert casesToInsert;

                List<Case> insertedCases = [SELECT Id, CaseNumber, Subject FROM Case WHERE Id IN :casesToInsert];

                result.success = true;
                result.message = 'Successfully created ' + caseCount + ' case(s)';
                result.cases = insertedCases;
                result.caseCount = caseCount;

                System.debug('✅ ' + caseCount + ' cases created successfully');
                for (Case c : insertedCases) {
                    System.debug('   Case: ' + c.CaseNumber + ' - ' + c.Subject);
                }
            } else {
                System.debug('⚠️ No valid items found for case creation');
                result.success = false;
                result.message = 'No valid items found for case creation';
            }

        } catch (Exception e) {
            System.debug('❌ Error creating cases: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
            result.success = false;
            result.message = 'Failed to create cases: ' + e.getMessage();
        }
        System.debug('🔵 [END] createCases returning: ' + JSON.serialize(result));
        return result;
    }

    /**
     * Update backend for "Not Interested" items (Legacy - kept for backward compatibility)
     */
    @AuraEnabled
    public static UpdateResult updateNotInterested(Id accountId, List<SelectedItem> selectedItems) {
        System.debug('🔵 [START] updateNotInterested (legacy) called with accountId: ' + accountId);
        UpdateResult result = updateProductDecisions(accountId, selectedItems);
        System.debug('🔵 [END] updateNotInterested returning: ' + JSON.serialize(result));
        return result;
    }

    // ==================== PRIVATE HELPER METHODS ====================

    private static Account getAccountDetails(Id accountId) {
        System.debug('🔍 getAccountDetails for Id: ' + accountId);
        try {
            List<Account> accounts = [SELECT Id, CIF__pc, x_canary__pc, Region_Flag__pc
                                     FROM Account
                                     WHERE Id = :accountId
                                     LIMIT 1];
            Account acc = accounts.isEmpty() ? null : accounts[0];
            System.debug('✅ Account found: ' + (acc != null ? acc.Id : 'null'));
            return acc;
        } catch (Exception e) {
            System.debug('❌ Error fetching account: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
            return null;
        }
    }

    private static NBOData parseNBOData(String responseBody) {
        System.debug('🔵 [START] parseNBOData');
        NBOData result = new NBOData();

        try {
            Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('🔍 Parsed response structure: ' + parsedResponse.keySet());

            if (parsedResponse.containsKey('meta')) {
                Map<String, Object> meta = (Map<String, Object>) parsedResponse.get('meta');
                String code = (String) meta.get('code');
                String message = (String) meta.get('message');
                System.debug('🔍 Meta: code=' + code + ', message=' + message);
                if (!'NBO-0000'.equals(code)) {
                    throw new AuraHandledException('API Error: ' + code + ' - ' + message);
                }
            } else {
                System.debug('⚠️ No "meta" key in response.');
            }

            if (parsedResponse.containsKey('data') && parsedResponse.get('data') != null) {
                Map<String, Object> data = (Map<String, Object>) parsedResponse.get('data');
                System.debug('🔍 Data keys: ' + data.keySet());

                if (data.containsKey('products') && data.get('products') != null) {
                    List<Object> productsList = (List<Object>) data.get('products');
                    System.debug('📦 Found ' + productsList.size() + ' products in response.');
                    for (Object productObj : productsList) {
                        Map<String, Object> productMap = (Map<String, Object>) productObj;
                        ProductWrapper product = new ProductWrapper();
                        product.id = (String) productMap.get('productCode');
                        product.name = (String) productMap.get('productCode');
                        product.confidenceScore = (Double) productMap.get('confidenceScore');

                        if (String.isBlank(product.id)) product.id = '';
                        if (String.isBlank(product.name)) product.name = '';
                        if (product.confidenceScore == null) product.confidenceScore = 0.0;

                        result.products.add(product);
                        System.debug('   Product: id=' + product.id + ', placeholder name=' + product.name + ', score=' + product.confidenceScore);
                    }
                } else {
                    System.debug('ℹ️ No "products" key in data.');
                }

                if (data.containsKey('offers') && data.get('offers') != null) {
                    List<Object> offersList = (List<Object>) data.get('offers');
                    System.debug('📦 Found ' + offersList.size() + ' offers in response.');
                    for (Object offerObj : offersList) {
                        Map<String, Object> offerMap = (Map<String, Object>) offerObj;
                        OfferWrapper offer = new OfferWrapper();
                        offer.id = (String) offerMap.get('offerId');
                        offer.name = (String) offerMap.get('offerId');
                        offer.confidenceScore = (Double) offerMap.get('confidenceScore');

                        if (String.isBlank(offer.id)) offer.id = '';
                        if (String.isBlank(offer.name)) offer.name = '';
                        if (offer.confidenceScore == null) offer.confidenceScore = 0.0;

                        result.offers.add(offer);
                        System.debug('   Offer: id=' + offer.id + ', placeholder name=' + offer.name + ', score=' + offer.confidenceScore);
                    }
                } else {
                    System.debug('ℹ️ No "offers" key in data.');
                }

                result.cif = (String) data.get('cif');
                System.debug('🔑 CIF: ' + result.cif);
            } else {
                System.debug('⚠️ No "data" key in response.');
            }

            System.debug('✅ Parsed ' + result.products.size() + ' products and ' + result.offers.size() + ' offers');

        } catch (JSONException je) {
            System.debug('❌ JSON parsing error: ' + je.getMessage());
            System.debug('❌ Stack trace: ' + je.getStackTraceString());
            throw new AuraHandledException('Invalid response format from API');
        }
        System.debug('🔵 [END] parseNBOData');
        return result;
    }

    /**
     * Call PATCH API to update product decisions.
     *
     * ✅ FIX #1: Endpoint was appending '+ ss' producing '/itemsss' → 404.
     * ✅ FIX #2: This method no longer throws AuraHandledException (which
     *            always surfaces as "Script-thrown exception" to the caller).
     *            Instead it returns:
     *              - null  → success
     *              - String → the real error message from the API / exception
     */
    private static String callPatchAPI(Account account, String requestBodyJson) {
        System.debug('🔵 [START] callPatchAPI');
        try {
            String xCanaryValue = String.isNotBlank(account.x_canary__pc) ? account.x_canary__pc : 'cbs';
            String regionName = String.isNotBlank(account.Region_Flag__pc) ? account.Region_Flag__pc : 'Bahrain';
            String customerId = account.CIF__pc;

            // ✅ FIXED ENDPOINT — '/items', not '/itemsss'
            String endpoint = NBO_BASE_PATH
                            + EncodingUtil.urlEncode(customerId, 'UTF-8')
                            + NBO_ITEMS_PATH;
            System.debug('🔗 PATCH Endpoint: ' + endpoint);

            HttpRequest req = con.createRequest('PATCH', endpoint, customerId, regionName);
            req.setHeader('x-canary', xCanaryValue);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBodyJson);
            req.setTimeout(TIMEOUT_MS);

            System.debug('📤 NBO PATCH API Request: ' + endpoint);
            System.debug('📤 x-canary: ' + xCanaryValue);
            System.debug('📤 Request Body: ' + requestBodyJson);

            Http http = new Http();
            HttpResponse response = http.send(req);

            System.debug('📥 NBO PATCH API Response Status: ' + response.getStatusCode());
            System.debug('📥 Response Body: ' + response.getBody());

            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                System.debug('✅ PATCH succeeded (' + response.getStatusCode() + ')');
                return null;
            }

            // Build a readable error message from the response
            String errorMsg = 'API returned status: ' + response.getStatusCode();
            if (String.isNotBlank(response.getBody())) {
                try {
                    Map<String, Object> errorResponse =
                        (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    if (errorResponse.containsKey('detail')) {
                        errorMsg = (String) errorResponse.get('detail');
                    } else if (errorResponse.containsKey('meta')) {
                        Map<String, Object> meta = (Map<String, Object>) errorResponse.get('meta');
                        errorMsg = meta.get('code') + ' - ' + meta.get('message');
                    } else if (errorResponse.containsKey('message')) {
                        errorMsg = (String) errorResponse.get('message');
                    } else {
                        errorMsg += ' - ' + response.getBody();
                    }
                } catch (Exception ignore) {
                    errorMsg += ' - ' + response.getBody();
                }
            }
            System.debug('❌ PATCH failed: ' + errorMsg);
            return errorMsg;

        } catch (Exception e) {
            System.debug('❌ Exception in PATCH API call: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
            return 'Exception: ' + e.getMessage();
        } finally {
            System.debug('🔵 [END] callPatchAPI');
        }
    }

    private static Id getCaseRecordTypeId() {
        System.debug('🔍 getCaseRecordTypeId');
        try {
            List<RecordType> rtList = [SELECT Id FROM RecordType
                                      WHERE SObjectType = 'Case'
                                      AND (DeveloperName = 'Internal_Case' OR Name = 'Internal Case')
                                      LIMIT 1];

            if (!rtList.isEmpty()) {
                System.debug('✅ Found Internal Case Record Type: ' + rtList[0].Id);
                return rtList[0].Id;
            }

            List<RecordType> allRTs = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' LIMIT 1];
            if (!allRTs.isEmpty()) {
                System.debug('✅ Found any Case Record Type: ' + allRTs[0].Id);
                return allRTs[0].Id;
            }

            System.debug('⚠️ No Case Record Type found.');
            return null;

        } catch (Exception e) {
            System.debug('❌ Error getting Case Record Type: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
            return null;
        }
    }

    private static Id getNBOQueueId() {
        System.debug('🔍 getNBOQueueId');
        try {
            List<Group> queues = [SELECT Id FROM Group
                                 WHERE Type = 'Queue'
                                 AND (DeveloperName = 'NBO_Sales_Queue' OR Name = 'NBO Sales Queue')
                                 LIMIT 1];

            if (!queues.isEmpty()) {
                System.debug('✅ Found NBO Sales Queue: ' + queues[0].Id);
                return queues[0].Id;
            }

            String queueId = System.Label.NBO_Sales_Queue;
            if (String.isNotBlank(queueId)) {
                try {
                    Id id = Id.valueOf(queueId);
                    System.debug('✅ Found NBO Sales Queue from label: ' + id);
                    return id;
                } catch (Exception e) {
                    System.debug('⚠️ Invalid Queue ID in label: ' + queueId);
                }
            }

            System.debug('⚠️ No NBO Sales Queue found.');
            return null;

        } catch (Exception e) {
            System.debug('❌ Error getting NBO Queue: ' + e.getMessage());
            System.debug('❌ Stack trace: ' + e.getStackTraceString());
            return null;
        }
    }

    // ==================== WRAPPER CLASSES ====================

    public class NBOData {
        @AuraEnabled public String cif { get; set; }
        @AuraEnabled public List<ProductWrapper> products { get; set; }
        @AuraEnabled public List<OfferWrapper> offers { get; set; }

        public NBOData() {
            this.products = new List<ProductWrapper>();
            this.offers = new List<OfferWrapper>();
        }
    }

    public class ProductWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Double confidenceScore { get; set; }
    }

    public class OfferWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Double confidenceScore { get; set; }
    }

    public class SelectedItem {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String itemType { get; set; }
        @AuraEnabled public String customerInterest { get; set; }
    }

    public class CaseCreationResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Integer caseCount { get; set; }
        @AuraEnabled public List<Case> cases { get; set; }

        public CaseCreationResult() {
            this.success = false;
            this.message = '';
            this.caseCount = 0;
            this.cases = new List<Case>();
        }
    }

    public class UpdateResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public Integer updatedCount { get; set; }

        public UpdateResult() {
            this.success = false;
            this.message = '';
            this.updatedCount = 0;
        }
    }
}