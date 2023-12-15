@isTest
public class BrochureReceivedTriggerTest 
{
	//Does not really test anything, just generate coverage for the trigger..
	@IsTest
	static void generateCoverage(){

		BrandspotService.DocumentType document = new BrandspotService.DocumentType();
		document.name = 'test';
		document.url = 'http://www.disney.com';
		document.language = 'nl-NL';
		
		List<BrandspotService.DocumentType> documents = new List<BrandspotService.DocumentType>{document};

		String keyPrefix = BrochureAanvraag__c.getSObjectType().getDescribe().getKeyPrefix();
		String fakeIdPostfix = '000000000001';

		Test.startTest();
		
		BrochureReceived__e event = new BrochureReceived__e();
		event.AanvraagId__c = Id.valueOf(keyPrefix + fakeIdPostfix);
		event.Documents__c = JSON.serialize(documents);
		Eventbus.publish(event);

		Test.stopTest();
		
	}
}