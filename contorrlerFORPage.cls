/**
 * Created by Eugene Lanets on 20.11.2020.
 */

public with sharing class el_HardwareOnlyPageController {

    public String quoteId;
    private Boolean isLWC = false;
    ApexPages.StandardController sc;

    public el_HardwareOnlyPageController(ApexPages.StandardController sc){
        this.sc = sc;
        System.debug(ApexPages.CurrentPage());
        quoteId = ApexPages.CurrentPage() != null ? ApexPages.CurrentPage().getParameters().get('id') : '';
        if(ApexPages.CurrentPage() == null){
            isLWC = true;
        }
    }

    public PageReference init(){

        SBQQ__Quote__c q = [SELECT Order_Notes_Instructions__c, SBQQ__Opportunity2__r.Type FROM SBQQ__Quote__c WHERE Id = :quoteId];

        if(!isLWC) {

            if (q.SBQQ__Opportunity2__r.Type == 'SaaS Only') {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Opportunity type Base Plan Change. To generate a document, use the SasS Only button.');
                ApexPages.addMessage(msg);
                return null;
            }

            if (q.Order_Notes_Instructions__c == null) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, 'Can\'t generate document if Order Notes & Instructions is null');
                ApexPages.addMessage(msg);
                return null;
            }

        }

        PageReference pr = Page.el_HardwareOnlyTemplatePDF;
        pr.getParameters().put('qid', quoteId);
        Blob body;
        if (!Test.isRunningTest()) {
            body = pr.getContent();
        } else {
            body = Blob.valueOf('Test Content');
        }

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = 'HardwareOnly.pdf';
        cv.Title = 'Hardware Only | '+Datetime.now().format()+'.pdf';
        cv.VersionData = body;

        insert cv;

        ContentVersion cv1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = quoteId;
        cdl.ContentDocumentId = cv1.ContentDocumentId;
        insert cdl;

        if(!isLWC) {
            PageReference prc = new PageReference('/' + cv1.ContentDocumentId);
            prc.setRedirect(true);
            return prc;
        }
        return null;
    }

    public PageReference backToQuote() {
        PageReference acctPage = new PageReference('/' + quoteId);
        acctPage.setRedirect(true);
        return acctPage;
    }
}
