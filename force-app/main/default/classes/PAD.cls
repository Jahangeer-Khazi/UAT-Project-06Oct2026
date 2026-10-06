public class PAD {  
    
    /**
     * @author ANISS MBARKI
     * @date Création 14/12/2021
     * @date Modification 
     * @description sytem.debug information at the start of a call
     * @param className Name of class
     * @param methodName Name of method
     * @param message Information to display in the logs
     * @return N/A
     */
    public static void debugLogBegin(String className, String methodName, String message){
        system.debug('## >> BEGIN ['+className+']['+methodName+'][MESSAGE]: '+message);
    }
     
    /** 
     * @author ANISS MBARKI
     * @date Création 14/12/2021
     * @date Modification 
     * @description sytem.debug information at the start of a call
     * @param className Name of class
     * @param methodName Name of method
     * @param message Information to display in the logss
     * @return N/A
     */
    public static void debugLogEnd(String className, String methodName, String message){
       system.debug('## >> END ['+className+']['+methodName+'][MESSAGE]: '+message);
    }
     
    /** 
     * @author ANISS MBARKI
     * @date Création 14/12/2021
     * @date Modification 
     * @description sytem.debug information at the start of a call
     * @param className Name of class
     * @param methodName Name of method
     * @param message Information to display in the logss
     * @return N/A
     */
    public static void debugLogInfo(String className, String methodName, String message){
       system.debug('## >> INFO ['+className+']['+methodName+'][MESSAGE]: '+message);
    }
}