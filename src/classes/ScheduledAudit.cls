global class ScheduledAudit implements Schedulable{
    global void execute(SchedulableContext ctx) {
        OrgDataExtractor_Controller o = new OrgDataExtractor_Controller([SELECT ID, Instance_Type__c, Access_Token__c, Instance_URL__c, Client_ID__c, Client_Secret__c, Redirect_URI__c, Refresh_Token__c 
                   FROM oAuth__c]);
    }
}