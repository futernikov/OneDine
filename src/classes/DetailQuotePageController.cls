/**
 * Created by Eugene Lanets on 12.10.2020.
 */

public with sharing class DetailQuotePageController {

    public Id quoteId;
    ApexPages.StandardController sc;

    public DetailQuotePageController(ApexPages.StandardController sc){
        this.sc = sc;
        quoteId = (Id)ApexPages.CurrentPage().getParameters().get('id');
    }

    public PageReference init(){
        PageReference pr = Page.DetailQuoteTemplatePDF;
        pr.getParameters().put('qid',quoteId);
        Blob body;
        if(!Test.isRunningTest()){
            body = pr.getContent();
        }else{
            body = Blob.valueOf('Test Content');
        }

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = 'DetailQuote.pdf';
        cv.Title = 'Detail Quote';
        cv.VersionData = body;

        insert cv;

        ContentVersion cv1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = quoteId;
        cdl.ContentDocumentId = cv1.ContentDocumentId;
        insert cdl;


        PageReference prc = new PageReference('/'+ cv1.ContentDocumentId);
        prc.setRedirect(true);
        return prc;
    }
}