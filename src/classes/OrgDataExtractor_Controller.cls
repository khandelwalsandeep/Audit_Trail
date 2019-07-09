public class OrgDataExtractor_Controller {
    Records auditData;
    oAuth__c orgData;
    public oAuth__c dateRange = new oAuth__c();
    public oAuth__c getdateRange(){ return dateRange; }
    public void setdateRange(oAuth__c o){}
    public Boolean success {get;set;}   //To check the success of data fetched from the desired org.
    public String docId {get;set;}
    public List<auditDataWrapper> auditDataWrapperList {get;set;}
    public String documentData = 'Date, Email, Name, Action, Section, Delegate User'+'"\n';
    private Integer MAX_LIMIT = 0;
    public OrgDataExtractor_Controller(){
        success = false;
        auditDataWrapperList = new List<auditDataWrapper>();
        String id = ApexPages.currentPage().getParameters().get('orgId');
        orgData = [SELECT ID,Name,Instance_Type__c, Access_Token__c, Instance_URL__c, Client_ID__c, Client_Secret__c, Redirect_URI__c, Refresh_Token__c 
                   FROM oAuth__c WHERE Id=:id];
    }
    //Added parameterised constructor for scheduling    
   /* public OrgDataExtractor_Controller(List<oAuth__c> orgDataList){
        auditDataWrapperList = new List<auditDataWrapper>();
        for(oAuth__c o : orgDataList){
            dateRange.Start_Date__c = Date.today();
            dateRange.End_Date__c = Date.today();
            orgData = o;
            extractAudit();
        }
    }*/
      public OrgDataExtractor_Controller(oAuth__c org){
          system.debug('dddd11'+org);
        auditDataWrapperList = new List<auditDataWrapper>();
            dateRange.Start_Date__c = Date.today();
            dateRange.End_Date__c = Date.today();
            orgData = org;
          system.debug('dddd'+orgData);
          	 extractAudit();
    }
    public void extractAudit(){
        Records tempRecords;
        DateTime sDate = DateTime.newInstance(dateRange.Start_Date__c.year(),dateRange.Start_Date__c.month(),dateRange.Start_Date__c.day(), 01, 01, 00);
        DateTime eDate = DateTime.newInstance(dateRange.End_Date__c.year(),dateRange.End_Date__c.month(),dateRange.End_Date__c.day(), 23, 59, 00);
        System.debug('Input Start date by user : '+dateRange.Start_Date__c);
        //String startDate = dateRange.Start_Date__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        //String endDate = dateRange.End_Date__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String startDate = sDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String endDate = eDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        System.debug('Start Date after clicking on fetch : '+startDate);
        String accessToken;
        //updated for excluding user functionality
        String query;
         List<AuditTrailUserSet__c> userList = AuditTrailUserSet__c.getAll().values();
        List<ID> uIdList = new List<ID>();
        String userid='';
        for(AuditTrailUserSet__c uId : userList){
            uIdList.add(uId.User_Id__c);
            if(userid==''){
                userid='\''+uId.User_Id__c+'\'';
            }
            else{
                userid=userid+','+'\''+uId.User_Id__c+'\'';
            }
        }
        system.debug('dsdasd'+uIdList);
        if(uIdList.size()>0)
        query = '/services/data/v38.0/query/?q=SELECT+Action,CreatedById,CreatedBy.Name,CreatedBy.Email,CreatedDate,DelegateUser,Display,Id,Section+FROM+SetupAuditTrail+WHERE+CreatedById+NOT+IN+('+userid+')+AND+CreatedDate+>+'+startDate+'+AND+CreatedDate+<+'+endDate+'ORDER+BY+CreatedDate+DESC';  
        else
        query = '/services/data/v38.0/query/?q=SELECT+Action,CreatedById,CreatedBy.Name,CreatedBy.Email,CreatedDate,DelegateUser,Display,Id,Section+FROM+SetupAuditTrail+WHERE+CreatedDate+>+'+startDate+'+AND+CreatedDate+<+'+endDate+'ORDER+BY+CreatedDate+DESC';
        //String query = '/services/data/v38.0/query/?q=SELECT+Action,CreatedById,CreatedBy.Name,CreatedBy.Email,CreatedDate,DelegateUser,Display,Id,Section+FROM+SetupAuditTrail+ORDER+BY+CreatedDate+DESC+LIMIT+20';
        //end of changes
        if(!validateAccessToken(orgData.Access_Token__c, orgData.Instance_URL__c, query)){  //This means access token is expired
            accessToken = generateAccessToken(orgData);
        }
        else accessToken = orgData.Access_Token__c;
        system.debug('Updated access token after refetching the access token:: '+accessToken);
        tempRecords = fetchData(accessToken, orgData.Instance_URL__c, query);
        createAuditWrapper(tempRecords);
        while(tempRecords.nextRecordsUrl != NULL){
            tempRecords = fetchData(accessToken, orgData.Instance_URL__c, tempRecords.nextRecordsUrl);
            createAuditWrapper(tempRecords);
        }
        success = TRUE;
        //createDocument();
        sendEmail();
        //Updating the exisiting org's auth details access token
        orgData.Access_Token__c = accessToken;
        //update orgData;
    }
    private Boolean validateAccessToken(String accessToken, String instanceURL, String query){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp;
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        if(accessToken != null){
            System.debug('Inside if access');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setEndpoint(instanceURL+query);
            req.setTimeout(60000);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not accessible : Access Token is NULL'));
        }
        if(!Test.isRunningTest()){
            resp = h.send(req);
            if(resp.getStatusCode()!=200)
                return false;
            
            system.debug('validate access token response :: '+resp.getBody());
            
        }
        return true; 
    }
    private Records fetchData(String accessToken, String instanceURL, String query){
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp;
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        if(accessToken != null){
            System.debug('Inside if access');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setEndpoint(instanceURL+query);
            req.setTimeout(60000);
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not accessible : Unable to fetch'));
        }
        if(!Test.isRunningTest()){
            resp = h.send(req);
            if(resp.getStatusCode()!=200)
                return NULL;
            auditData = (Records)JSON.deserialize(resp.getBody(), Records.class);
            system.debug('After Query... resp.getBody():: sandeep'+resp.getBody());
        }
        return auditData;    
    }
    
    public void createAuditWrapper(Records auditData){
        
        for(Integer i=0;i<auditData.records.size();i++){
            MAX_LIMIT++;
            auditDataWrapper aTObj = new auditDataWrapper();
            String formatedDate;
            if(auditData != NULL){
                //formatedDate = auditData.records[i].CreatedDate.format('MM/dd/yyyy HH:mm:ss','IST');
                aTObj.id = auditData.records[i].Id != NULL ? auditData.records[i].Id : '';
                aTObj.display = auditData.records[i].Display != NULL ? auditData.records[i].Display : '';
                aTObj.section = auditData.records[i].Section != NULL ? auditData.records[i].Section : '';
                aTObj.createdByName = (auditData.records[i].CreatedBy != NULL && auditData.records[i].CreatedBy.Name != NULL) ? auditData.records[i].CreatedBy.Name : '';
                aTObj.createdByEmail = (auditData.records[i].CreatedBy != NULL && auditData.records[i].CreatedBy.Email != NULL) ? auditData.records[i].CreatedBy.Email : '';
                aTObj.createdDate = auditData.records[i].CreatedDate != NULL ? auditData.records[i].CreatedDate.format('MM/dd/yyyy HH:mm:ss','BST') : '';
                aTObj.delegateUser = auditData.records[i].DelegateUser != NULL ? auditData.records[i].DelegateUser : '';
                if(MAX_LIMIT <= 20){
                    system.debug('Inside MAX_LIMIT '+MAX_LIMIT);
                    auditDataWrapperList.add(aTObj);
                }
                system.debug('auditDataWrapper Details :: '+aTObj);
                //documentData += '"'+aTObj.Id+'","'+aTObj.display+'","'+aTObj.createdByName+'","'+aTObj.createdByEmail+'","'+aTObj.createdDate+'"\n';
                documentData += '"'+aTObj.createdDate+'","'+aTObj.createdByEmail+'","'+aTObj.createdByName+'","'+aTObj.display+'","'+aTObj.section+'","'+aTObj.delegateUser+'"\n';
                
            }
        }
    }
    
    public void createDocument(){
        Document acmDoc = new Document();
        acmDoc.Name = 'Audit Data FROM '+dateRange.Start_Date__c.format()+' TO '+dateRange.End_Date__c.format();
        acmDoc.Type = 'csv';
        acmDoc.body = Blob.valueOf(documentData);
        List<Document> documents = [SELECT Id, FolderId, Folder.Name FROM Document WHERE Folder.Name = 'AuditTrail Extract' LIMIT 1];
        //acmDoc.FolderId = '00l7F000000h85a';
        acmDoc.FolderId = documents[0].FolderId;
        insert acmDoc;
        docId = acmDoc.Id;
        
    }

    public  void sendEmail(){
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        //Custom setting which stores the list of Email ID's of the users which should be kept in cc.
        List<Recipient_List__c> recList = Recipient_List__c.getAll().values();
        String[] toAddress = new List<String>();
        for(Recipient_List__c eml : recList){
            toAddress.add(eml.Email_Id__c);
        }
        
        //Set the content into the attachment.
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        String body = 'Hi, \n\n PFA attached audit files of'+' '+orgData.Name;
        email.setToAddresses(toAddress);
        blob csvBlob = Blob.valueOf(documentData);
        String csvname = 'Audit'+' '+orgData.Name+'.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        email.setPlainTextBody(body);
        email.setSubject('Audit Files of'+' '+orgData.Name);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
    public String generateAccessToken(oAuth__c oAuth){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        System.debug('oAuth value :: '+oAuth);
        request.setMethod('POST');
        request.setEndpoint('https://'+oAuth.Instance_Type__c+'.salesforce.com/services/oauth2/token');
        String body = 'grant_type=refresh_token';
        body += '&refresh_token='+oAuth.Refresh_Token__c;
        body += '&client_id='+oAuth.Client_ID__c;
        body += '&client_secret='+oAuth.Client_Secret__c;
        request.setBody(body);
        response = new Http().send(request);
        system.debug('updated access token :: '+response.getBody());
        RefreshTokenResponse rtr = (RefreshTokenResponse)JSON.deserialize(response.getBody(), RefreshTokenResponse.class);
        
        return rtr.access_Token;
        //Update the OAuth__c custom object data as per received from the response.
        
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
    
    public class RefreshTokenResponse {
        public String access_Token{get;set;}   
        public String instance_Url{get;set;}
        public String id{get;set;}
        public String issued_At{get;set;}
        public String signature{get;set;}
    }
    
    public class Records{
        public Integer totalSize;
        public boolean done;
        public String nextRecordsUrl;
        public cls_records[] records;
    }
    
    public class cls_records {
        public cls_attributes attributes;
        public String Action;   
        public String CreatedById;
        public cls_CreatedBy CreatedBy;
        public DateTime CreatedDate;  
        public String DelegateUser;
        public String Display;  
        public String Id;   
        public String Section;
    }
    
    public class cls_CreatedBy {
        public cls_attributes attributes;
        public String Name; 
        public String Email;
    }
    
    public class cls_attributes {
        public String type;
        public String url;  
    }
    
    public class auditDataWrapper {
        public String Id {get;set;}
        public String Section {get;set;}
        public String display {get;set;}
        public String createdByName {get;set;}
        public String createdByEmail {get;set;}
        public String createdDate {get;set;}
        public String delegateUser {get;set;}
        
    }
}