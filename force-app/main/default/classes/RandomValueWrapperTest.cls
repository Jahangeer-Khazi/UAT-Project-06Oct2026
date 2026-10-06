/**
 * @description       : 
 * @author            : Jose Caballero
 * @group             : 
 * @last modified on  : 19/10/2021
 * @last modified by  : Jose Caballero
**/
@isTest
public with sharing class RandomValueWrapperTest {
    
    @isTest
    static void generateRandomValueWrapperList() {
        String [] alphabet = new List<String> { 'a' , 'b' , 'c', 'd'};
        RandomValueWrapper [] wrapperList = new List<RandomValueWrapper>();

        for(String letter : alphabet) {
            wrapperList.add(new RandomValueWrapper(letter));            
        }

        wrapperList.sort();

        System.Assert(wrapperList[0].random <= wrapperList[1].random, 'List should be ordered by random assigned values');
        System.Assert(wrapperList[1].random <= wrapperList[2].random, 'List should be ordered by random assigned values');
        System.Assert(wrapperList[2].random <= wrapperList[3].random, 'List should be ordered by random assigned values');
    }
}