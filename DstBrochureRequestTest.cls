//
//  May 24, 2019
//  Dennis Stahlhofen | Stahlhofen Development | Force.com
//
//  Class DstBrochureRequestTest
//
@isTest
public class DstBrochureRequestTest {

  @TestSetup
  static void createDate() {

    BrandspotSettings__c settings = new BrandspotSettings__c();
    settings.Debug__c = true;
    settings.Endpoint__c = 'https://some-fancy-endpoint.org';
    settings.Key__c = 'SoMeFaNcYkEy123';
    insert settings;

    Account account = new Account();
    account.Name = 'Test Account';
    insert account;

    Contact contact = new Contact();
    contact.AccountId = account.Id;
    contact.FirstName = 'First';
    contact.LastName = 'Last';
    contact.Email = 'first.last@hu-org.dev';
    insert contact;

    list < Account > academicPrograms = new list < Account >();
    Id academicProgramRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
    academicPrograms.add( new Account(Name = 'Accountancy', CordeoID__c = '25DW-00-34406-V-BMAC', RecordTypeId = academicProgramRecordTypeId) );
    academicPrograms.add( new Account(Name = 'Bedrijfskunde', CordeoID__c = '25DW-00-34435-V-BMME', RecordTypeId = academicProgramRecordTypeId) );
    academicPrograms.add( new Account(Name = 'Built Environment', CordeoID__c = '25DW-00-39280-V-BTBNBE', RecordTypeId = academicProgramRecordTypeId) );
    academicPrograms.add( new Account(Name = 'Chemie', CordeoID__c = '25DW-00-34396-V-BTLCCY', RecordTypeId = academicProgramRecordTypeId) );
    academicPrograms.add( new Account(Name = 'Communicatie', CordeoID__c = '25DW-00-34405-V-BJCM', RecordTypeId = academicProgramRecordTypeId) );
    insert academicPrograms;

  }

  @isTest
  static void testBrochureAanvraagRequest() {

    Id contactId = [Select Id From Contact Limit 1].Id;
    Id initieelRecordTypeId = Schema.SObjectType.BrochureAanvraag__c.getRecordTypeInfosByName().get('Initieel').getRecordTypeId();

    list < Account > academicPrograms = [Select Id From Account Where RecordType.Name = 'Academic Program'];
    System.assert (academicPrograms.size() == 5);

    BrochureAanvraag__c bag = new BrochureAanvraag__c();
    bag.Contactpersoon__c = contactId;
    bag.Brochure3__c = academicPrograms[0].Id;
    bag.Brochure9__c = academicPrograms[1].Id;
    bag.Brochure15__c = academicPrograms[2].Id;
    bag.AcademicProgram1__c = academicPrograms[3].Id;

    insert bag;

    String jsonStr = '{"owned_by":"abcdefghijklmnopqrstuvwxyz","documents":[{"name":"Klik hier voor - nl-NL","url":"https://hu.brandspot.org/bot/wrd/CheckLnk?id=313&taal=nl-NL","courses":["Farmakunde"],"language":"nl-NL"},{"name":"Klik hier voor - en-US","url":"https://hu.brandspot.org/bot/wrd/CheckLnk?id=313&taal=en-US","courses":["Farmakunde. maar dan Engels"],"language":"en-US"}],"api_key":"SoMeFaNcYkEy123"}';
    
    RestRequest req = new RestRequest();
    req.httpMethod = 'POST';
    req.requestURI = '/brandspot/';
    req.requestBody = Blob.valueOf(jsonStr);
    
    RestContext.request = req;
    RestContext.response = new RestResponse();
    DstRestCordeoBrandspot.restBrandspotPost();

    // Request fails because passed Id doesn't exist
    System.assert(RestContext.response.responseBody == null);

    // Now add the right Id
    jsonStr = jsonStr.replace('abcdefghijklmnopqrstuvwxyz', bag.Id);

    // And send again
    req = new RestRequest();
    req.httpMethod = 'POST';
    req.requestURI = '/brandspot/';
    req.requestBody = Blob.valueOf(jsonStr);

    RestContext.request = req;
    RestContext.response = new RestResponse();
    DstRestCordeoBrandspot.restBrandspotPost();
    String retVal = RestContext.response.responseBody.toString();
    System.assertEquals('Message successfully received', retVal);
  }
}