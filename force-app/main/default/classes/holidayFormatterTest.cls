@isTest
private class holidayFormatterTest {
    @isTest
    static void testHolidayDeserialization() {
        String jsonResponse = '{"meta": {"code": 200},"response": {"holidays": [{"name": "New Year\'s Day","description": "New Year’s Day is celebrated with a blend of both diversity and tradition in countries such as South Africa on January 1 each year.","country": {"id": "za","name": "South Africa"},"date": {"iso": "1987-01-01","datetime": {"year": 1987,"month": 1,"day": 1}},"type": ["National holiday"],"primary_type": "Public Holiday","canonical_url": "https://calendarific.com/holiday/south-africa/new-year-day","urlid": "south-africa/new-year-day","locations": "All","states": "All"}]}}';
        
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        Map<String, Object> response = (Map<String, Object>) parsedResponse.get('response');
        List<Object> holidays = (List<Object>) response.get('holidays');
        
        System.assertNotEquals(null, holidays, 'Holidays list should not be null');
        System.assert(holidays.size() > 0, 'Holidays list should contain at least one holiday');
        
        Object firstHoliday = holidays[0];
        String serializedHoliday = JSON.serialize(firstHoliday).replace('"date":', '"dateValue":');
        holidayFormatter.Holiday holiday = (holidayFormatter.Holiday) JSON.deserialize(serializedHoliday, holidayFormatter.Holiday.class);
        
        System.assertNotEquals(null, holiday, 'Holiday object should not be null');
        System.assertEquals('New Year\'s Day', holiday.name, 'Holiday name is correctly deserialized');
        System.assertEquals('1987-01-01', holiday.dateValue.iso, 'Holiday ISO date is correctly deserialized');
        System.assertEquals('za', holiday.country.id, 'Country ID is correctly deserialized');
        System.assertEquals('South Africa', holiday.country.name, 'Country name sis South Africa');
        System.assertEquals('Public Holiday', holiday.primary_type, 'Primary type is of tye Public holiday');
    }
}