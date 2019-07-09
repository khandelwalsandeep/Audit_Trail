global class BatchExtractor implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    public string q='SELECT ID,Name,Instance_Type__c, Access_Token__c, Instance_URL__c, Client_ID__c, Client_Secret__c, Redirect_URI__c, Refresh_Token__c FROM oAuth__c';
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(q);
        
    }
    global void execute (Database.BatchableContext BC, list<oAuth__c> records){   
        try{
          	
            for(oAuth__c oa:records){
              OrgDataExtractor_Controller Org = new OrgDataExtractor_Controller(oa); 
            }
        }
        catch(Exception e){
            system.debug('eeee');
        }
    }
    global void finish(Database.BatchableContext BC){   
      
    }  
}