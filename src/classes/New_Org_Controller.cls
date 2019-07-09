public class New_Org_Controller {
    public oAuth__c OAuthDetail = new oAuth__c();
    public oAuth__c getOAuthDetail(){ 
        /*   oAuth__c temp = new oAuth__c();
		Default_Connected_Settings__c def = Default_Connected_Settings__c.getInstance('Default');
		temp.Client_ID__c = def.Consumer_Key__c;
		temp.Client_Secret__c = def.Consumer_Secret__c;
		temp.Redirect_URI__c = def.Redirect_URI__c;
		return temp;
		*/
        return OAuthDetail;
    }
    public void setOAuthDetail(oAuth__c oa){
        /* OAuthDetail = new oAuth__c();
        OAuthDetail.Client_ID__c=oa.Client_ID__c;
        OAuthDetail.Client_Secret__c=oa.Client_Secret__c;
        OAuthDetail.Instance_Type__c=oa.Instance_Type__c;
        OAuthDetail.Redirect_URI__c=oa.Redirect_URI__c;*/
    }
    
    public New_Org_Controller(){
        Default_Connected_Settings__c def = Default_Connected_Settings__c.getInstance('Default');
        OAuthDetail = new oAuth__c();
        OAuthDetail.Client_ID__c = def.Consumer_Key__c;
        OAuthDetail.Client_Secret__c = def.Consumer_Secret__c;
        OAuthDetail.Redirect_URI__c = def.Redirect_URI__c;   
    }
    
    public PageReference authorize(){
        system.debug('New Org Contr');
        //get the oAuth object details and save it
        insert OAuthDetail;
        system.debug('OAuthDetail obj '+OAuthDetail);
        String baseUrl = 'https://'+OAuthDetail.Instance_Type__c+'.salesforce.com/services/oauth2/authorize?';
        String body = 'response_type=code&';
        body += 'client_id='+OAuthDetail.Client_ID__c;
        body += '&redirect_uri='+OAuthDetail.Redirect_URI__c;
        body += '&immediate=false&prompt=login%20consent';
        body += '&state='+OAuthDetail.Id;
        PageReference ref;
        ref = new PageReference(baseUrl+body);
        ref.setRedirect(true);
        return ref;
    }   
}