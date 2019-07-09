public class Exisiting_Org_Controller {
    public String selectedOrgID {get;set;}
    public List<SelectOption> listOfOrgs
    {
        get
        {
            listOfOrgs = new List<SelectOption>();
            listOfOrgs.add(new SelectOption('','--SELECT--'));
            for(oAuth__c o : [SELECT Id, Name FROM oAuth__c]){
                listOfOrgs.add(new SelectOption(o.Id, o.Name));
            }
            return listOfOrgs;
        }
        set;
    }
    
    public Exisiting_Org_Controller(){}
    
    public PageReference redirect(){
        PageReference ref = new PageReference('/apex/OrgDataExtractor');
        ref.getParameters().put('OrgId',selectedOrgID);
        ref.setRedirect(TRUE);
        return ref;
    }
}