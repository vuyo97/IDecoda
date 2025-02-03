public class holidayFormatter {
    public class Holiday {
        public String name;
        public String description;
        public Country country;
        public HolidayDate dateValue;
        public List<String> type;
        public String primary_type;
        public String canonical_url;
        public String locations;
        public String states;
    }

    public class Country {
        public String id;
        public String name;
    }

    public class HolidayDate {
        public String iso;
        public DayMonthYear DMY;
    }

    public class DayMonthYear{
        public Integer year;
        public Integer month;
        public Integer day;
    }
}