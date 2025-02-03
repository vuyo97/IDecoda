@isTest
public class IdentitySearchHandlerTest {
    @testSetup
    static void setupTestData() {
        Identity_Tracker__c testRecord = new Identity_Tracker__c(
            Identity_Number__c = '9703255009083',
            Date_Of_Birth__c = Date.valueOf('1997-03-25'),
            Gender__c = 'Male',
            SA_Citizen__c = true,
            Search_Count__c = 1
        );
        insert testRecord;
    }
    
    @isTest
    static void testProcessIDSearch_existingRecord() {
        String idNumber = '9703255009083';
        String dateOfBirth = '1997-03-25';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();        
        Map<String, String> result = IdentitySearchHandler.processIDSearch(idNumber, dateOfBirth);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    } 
    
    @isTest
    static void testProcessIDSearch_InvalidCallout() {
        String idNumber = '9703255009083';
        String dateOfBirth = 'bad_data';

        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();        
        Map<String, String> result = IdentitySearchHandler.processIDSearch(idNumber, dateOfBirth); 
        Test.stopTest();

        System.assertEquals(null, result.get('response'),'Result should be null');
    }
    
    @isTest
    static void testProcessIDSearch_newRecord() {
        String idNumber = '9703255009084'; 
        String dateOfBirth = '1997-03-25';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        Map<String, String> result = IdentitySearchHandler.processIDSearch(idNumber, dateOfBirth);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, [SELECT COUNT() FROM Identity_Tracker__c WHERE Identity_Number__c = :idNumber], 'New record successfully inserted');
    }
    
    @isTest
    static void testDecodeGenderAndCitizenShip() {
        String idNumber = '9703255009083';
        String dateOfBirth = '1997-03-25';
        
        Map<String, String> decodedInfo = IdentitySearchHandler.decodeGenderAndCitizenShip(idNumber, dateOfBirth);
        
        System.assertEquals('Male', decodedInfo.get('gender'));
        System.assertEquals('true', decodedInfo.get('citizen'));
    }
    
    @isTest
    static void testGetBirthdayPublicHolidays() {
        String dateOfBirth = '1997-03-25';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        Test.startTest();
        Map<String, String> holidays = IdentitySearchHandler.getBirthdayPublicHolidays(dateOfBirth);
        Test.stopTest();
        
        System.assertNotEquals(null, holidays, 'Holidays should not be null');
        System.assert(holidays.size() > 0, 'Holidays should contain values');
    }

    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('bad')){
                res.setStatusCode(400);
                res.setBody('[]');
             }else{
                res.setStatusCode(200);
                res.setBody('{"response": {"holidays": [{"name": "Test Holiday", "primary_type": "Public Holiday", "date": {"iso": "1997-03-25"}}]}}');
            }
            return res;
        }
    }
}


