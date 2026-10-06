/**
 * @description       : 
 * @author            : Jose Caballero
 * @group             : 
 * @last modified on  : 18/10/2021
 * @last modified by  : Jose Caballero
**/
public with sharing class RandomValueWrapper implements Comparable {
    
    @TestVisible Decimal random;
    public Object value;

    public RandomValueWrapper(Object value) {
        this.value = value;
        random = Math.random();
    }

    public Integer compareTo(Object otherObject) {
        RandomValueWrapper other = (RandomValueWrapper)otherObject;
        if(random > other.random) {
            return 1;
        } else if (random < other.random) {
            return -1;
        } else {            
            return 0;
        }
    }
}