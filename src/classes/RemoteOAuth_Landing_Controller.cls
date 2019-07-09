public class RemoteOAuth_Landing_Controller {
    public String responseReceived {get;set;}
    public oAuth__c oa;
    public RemoteOAuth_Landing_Controller(){
        //fetch the code from the url and generate refresh token for the particular oAuth record and insert the details.
        system.debug('RemoteOAuth_Landing_Controller :: Called');
        system.debug('RemoteOAuth_Landing_Controller :: State = '+ApexPages.currentPage().getParameters().get('state'));
        generateRefereshToken();
    }
    
    public void generateRefereshToken(){
        String authenticationCode = ApexPages.currentPage().getParameters().get('code');
        String orgId = ApexPages.currentPage().getParameters().get('state');
        if(authenticationCode != NULL){
            oa = [SELECT ID, Instance_Type__c, Access_Token__c, Instance_URL__c, Client_ID__c, Client_Secret__c, Redirect_URI__c, Refresh_Token__c FROM oAuth__c WHERE Id=:orgId];
            
            HttpRequest req = new HttpRequest();
            HttpResponse resp;
            String res,body;
            Http h;
            req.setEndpoint('https://'+oa.Instance_Type__c+'.salesforce.com/services/oauth2/token');
            req.setMethod('POST');
            String bod = 'code='+authenticationCode;
            bod += '&grant_type=authorization_code';
            bod += '&client_id='+oa.Client_ID__c;
            bod += '&redirect_uri='+oa.Redirect_URI__c;
            bod += '&client_secret='+oa.Client_Secret__c;
            req.setBody(bod);
            resp = new Http().send(req);
            
            if(resp.getStatusCode()!=200)
                responseReceived = 'Authentication Problem occured!!';
            else{
                responseReceived = 'Authentication was successfull';
            }
            system.debug('resp @ 55 '+resp.getBody());
            
            TokenResponse tr = (TokenResponse)JSON.deserialize(resp.getBody(), TokenResponse.class);
            String accessToken = tr.access_Token;
            String instanseURL = tr.instance_Url;
            String refreshToken = tr.refresh_Token;
            oa.Access_Token__c = accessToken;
            oa.Instance_URL__c = instanseURL;
            oa.Refresh_Token__c = refreshToken;
            //update oa;
        }
        
    }
    
    public PageReference extract(){
        if(oa!=null){ 
            update oa;
            PageReference ref = new PageReference('/apex/OrgDataExtractor');
            ref.getParameters().put('OrgId',oa.Id);
            ref.setRedirect(TRUE);
            return ref;
        }
        return null;
        
    }
    
    public class TokenResponse {
        
        public String access_Token{get;set;}
        public String refresh_Token{get;set;}
        public String signature{get;set;}
        public String scope{get;set;}
        public String id_Token{get;set;}
        public String instance_Url{get;set;}
        public String id{get;set;}
        public String token_Type{get;set;}
        public String issued_At{get;set;}
        
    }
}