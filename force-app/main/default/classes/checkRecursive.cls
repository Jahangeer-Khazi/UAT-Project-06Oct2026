/* 		Organization : ABC Bank
 * 		Created By: 
 *		Created Date:03-01-2022
 * 		Change History: 
 * 	 				 #CH01# #Jahangeer Mohammed# #31-05-2022# Added a method runOnceForCache(CRM22-108)
 * 					 #CH02# #Jahangeer Mohammed# 22-11-2022# Added a method runOnceForPeriodicReviewCase(CRM22-114)
 * 					 #CH03# #Jahangeer Mohammed# 24-08-2025# Added a logic to control recursion on updating Premium invitation (PI-4283)
 *
 *			  
*/
public Class checkRecursive{
    private static boolean run = true;
     //CH01: Start
    private static boolean runCache = true;
    //CH01: END
     //CH02: Start
    private static boolean runPeriodicReview = true;
	//CH02: END
	//CH03: Start
	private static boolean runCobrandedPremiumOnce = true;
    //CH03: END
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }
        else{
            return run;
        }
    }
    //CH01: Start
    public static boolean runOnceForCache(){
        if(runCache){
            runCache=false;
            return true;
        }
        else{
            return runCache;
        }
    }
    //CH01: END
     //CH02: Start
    public static boolean runOnceForPeriodicReviewCase(){
        if(runPeriodicReview){
            runPeriodicReview=false;
            return true;
        }
        else{
            return runPeriodicReview;
        }
    }
    //CH02: END
    //CH03: Start
     public static boolean runOnceForCobrandCards(){
        if(runCobrandedPremiumOnce){
            runCobrandedPremiumOnce=false;
            return true;
        }
        else{
            return runCobrandedPremiumOnce;
        }
    }
    //CH03: END
}