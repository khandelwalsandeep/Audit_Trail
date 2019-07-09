@IsTest
public class New_Org_ControllerTest {
@isTest
    public static void New_Org_ControllerTest(){
        
        PageReference ref = new PageReference('/apex/New_Org');
        Test.setCurrentPage(ref);
        
        Default_Connected_Settings__c def = new Default_Connected_Settings__c();
		def.Consumer_Key__c ='3MVG9d8..z.hDcPKi0FfJsntJ_KqwKlLxcxXVNyJxRVDkCaR3O1Tv9Cm9dBV4WnGBSPfxFcz9tDiy29QiQtwQ';
        def.Consumer_Secret__c ='4464332756932967623';
        def.Redirect_URI__c ='https://c.ap5.visual.force.com/apex/RemoteOAuth_Landing';
        def.Name = 'Default';
        Insert def;


        oAuth__c atnew = new oAuth__c(Name='TestAuth',Instance_Type__c = 'test', 
                                      Access_Token__c='00DO000000555jp!ARcAQMOytNt0uPOulhhLinx8sUtd8yPUx0K.WNf0oRshqhiPCPqKOMestq0oVbnviF4LUA.053Kakjisc24MpVi3gN8tWsdy', 
                                      Instance_URL__c='https://daimlerasia--RMPOC.cs5.my.salesforce.com', 
                                   	  Client_ID__c='3MVG9d8..z.hDcPKi0FfJsntJ_KqwKlLxcxXVNyJxRVDkCaR3O1Tv9Cm9dBV4WnGBSPfxFcz9tDiy29QiQtwQ', 
                                      Client_Secret__c='4464332756932967623', 
                                      Redirect_URI__c='https://c.ap5.visual.force.com/apex/RemoteOAuth_Landing', 
                                      Refresh_Token__c='5Aep86110KCjUDVVh0poo1QRzVpEQvHRcMYyh2_2LUbWqDEjvZQb9x4QEF7YYx7VKFagKQB2nVXklqfy4MhiSTZ');
                               
        New_Org_Controller NewOrg = new New_Org_Controller();
        NewOrg.OAuthDetail = atnew;
        NewOrg.authorize();
        
    }
}