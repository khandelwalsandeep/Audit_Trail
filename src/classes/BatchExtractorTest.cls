@isTest
public class BatchExtractorTest {
    
    @isTest
    public static void TestOAuth(){
        List<oAuth__c> newList = new  List<oAuth__c>();
        
        oAuth__c atnew = new oAuth__c(Name='TestAuth',Instance_Type__c = 'test', 
                                   Access_Token__c='00DO000000555jp!ARcAQMOytNt0uPOulhhLinx8sUtd8yPUx0K.WNf0oRshqhiPCPqKOMestq0oVbnviF4LUA.053Kakjisc24MpVi3gN8tWsdy', 
                                   Instance_URL__c='https://daimlerasia--RMPOC.cs5.my.salesforce.com', 
                                   Client_ID__c='3MVG9d8..z.hDcPKi0FfJsntJ_KqwKlLxcxXVNyJxRVDkCaR3O1Tv9Cm9dBV4WnGBSPfxFcz9tDiy29QiQtwQ', 
                                   Client_Secret__c='4464332756932967623', 
                                   Redirect_URI__c='https://c.ap5.visual.force.com/apex/RemoteOAuth_Landing', 
                                   Refresh_Token__c='5Aep86110KCjUDVVh0poo1QRzVpEQvHRcMYyh2_2LUbWqDEjvZQb9x4QEF7YYx7VKFagKQB2nVXklqfy4MhiSTZ');
    
        insert atnew;
        newList.add(atnew);
        
        String CRON_EXP = '0 0 0 2 6 ? 2022';
        
        BatchExtractor bc = new BatchExtractor();                
        ID batchprocessid = Database.executeBatch(bc);              
        String jobId = System.schedule('Create Connection', CRON_EXP, new ScheduleBatchExtractor());
    }

}