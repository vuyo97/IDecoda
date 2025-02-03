public without sharing class IdentitySearchHandler {
    @AuraEnabled(cacheable=false)  
    public static Map<String,String> processIDSearch(String idNumber, String dateOfBirth) {
        Map<String,String>  holidayList = new Map<String,String>();
        Map<String,String> decodedInformation = new Map<String,String>();

        decodedInformation = decodeGenderAndCitizenShip(idNumber,dateOfBirth); 
        String gender = decodedInformation.get('gender');
        Boolean isSACitizen = Boolean.valueOf(decodedInformation.get('citizen'));
        Identity_Tracker__c existingRecord;

         try{
            List<Identity_Tracker__c> existingRecords = [SELECT Id, Search_Count__c FROM Identity_Tracker__c WHERE Identity_Number__c = :idNumber LIMIT 1];
            if (!existingRecords.isEmpty()) { 
            existingRecord = existingRecords[0]; 
            }
            holidayList = getBirthdayPublicHolidays(dateOfBirth);

            if(existingRecord != null){
                existingRecord.Search_Count__c += 1;
                update existingRecord;

            } else {
                Identity_Tracker__c newRecord = new Identity_Tracker__c(
                    Identity_Number__c = idNumber,
                    Date_Of_Birth__c = Date.ValueOf(dateOfBirth),
                    Gender__c = gender,
                    SA_Citizen__c = isSACitizen,
                    Search_Count__c = 1
                );
                insert newRecord;
            }
        
            return holidayList; 

         } catch (Exception e) {
             throw new AuraHandledException(e.getMessage());

         } 
             
    }

    public static Map<String,String> decodeGenderAndCitizenShip(String idNumber, String dateOfBirth){
        Map<String,String> decodedInformation = new Map<String,String>();
        String genderCode = idNumber.substring(6, 10); 
        String citizenshipCode = idNumber.substring(10, 11); 

        String gender = (Integer.valueOf(genderCode) < 5000) ? 'Female' : 'Male';
        Boolean isSACitizen = (citizenshipCode == '0');

        decodedInformation.put('gender',gender);
        decodedInformation.put('citizen',isSACitizen.toString());
        return decodedInformation;
    }


    public static Map<String,String> getBirthdayPublicHolidays(String dateOfBirth) {
        String year = dateOfBirth.substring(0,4); 
        IDecoda_Credentials__mdt IDECODA_MDT = IDecoda_Credentials__mdt.getInstance('API_Key');
        STRING APIKEY = IDECODA_MDT.API_Key__c;

        String endpoint = 'callout:Calendarific_API/v2/holidays?&api_key='+ APIKEY +'&country=ZA&year=' + year;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String,String> holidaysMap = new Map<String,String> ();
        try{
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                Map<String,Object> response = (Map<String,Object> )responseBody.get('response');
                List<Object> holidays = (List<Object> )response.get('holidays');
        
                for (Object h : holidays) {
                String serializedData = JSON.serialize(h).replace('"date":', '"dateValue":');
                    holidayFormatter.Holiday holiday =  (holidayFormatter.Holiday )JSON.deserialize(serializedData, holidayFormatter.Holiday.class);

                    if(holiday.primary_type == 'Public Holiday'){
                    holidaysMap.put(holiday.dateValue.iso,holiday.name);
                    }
            
                }
            }
        } catch (Exception e) {            
            throw new CalloutException('Error calling Calendaric API: ' + res.getStatusCode());
        }
        return holidaysMap;
    }
}