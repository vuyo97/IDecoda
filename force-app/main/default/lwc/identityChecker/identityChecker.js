import { LightningElement,track } from 'lwc';
import processIDSearch from '@salesforce/apex/IdentitySearchHandler.processIDSearch';

export default class IdentityChecker extends LightningElement {
  @track idNumber = '';
  @track isSearchDisabled = true;
  @track holidayInfo = '';
  @track isSearchDisabled = true;
  @track errorMessage = '';
  @track showModal = false;

  handleInputChange(event) {
    this.idNumber = event.target.value;
    this.validateIdNumber();
  }

  validateIdNumber() {
    const regex = /^\d{13}$/; 
    if (regex.test(this.idNumber)) {
      const isValid = this.validateChecksum(this.idNumber);
      this.isSearchDisabled = !isValid;
      this.errorMessage = isValid ? '' : 'Invalid South African ID Number.';
    } else {
      this.isSearchDisabled = true;
      this.errorMessage = 'ID Number must be 13 numerical digits long.';
    }
  }

  validateChecksum(idNumber) {
    return true; 
  }

  handleSearch() {
    const dob = this.decodeDob(this.idNumber);
    this.saveResults(dob.toString());
  }

  decodeDob(idNumber) {
    const year = idNumber.substring(0, 2);
    const month = idNumber.substring(2, 4);
    const day = idNumber.substring(4, 6);
    const fullYear = year > 20 ? `19${year}` : `20${year}`;
    return `${fullYear}-${month}-${day}`;
  }

  saveResults(dob) {
    const holidays = [];
    const holidayList = {};
    processIDSearch({ idNumber: this.idNumber, dateOfBirth : dob })
      .then(result => {
        if(result != null){
          this.holidayResult = result;
          this.holidayList = Object.entries(this.holidayResult).map(([date, name]) => ({ date, name })); 
          this.holidays = this.holidayList.map(holiday => holiday.date);
          this.holidayList = this.holidayList.filter(holiday => new Date(holiday.date) >= new Date(dob));
          this.showModal = true;

        }

        if (holidays.includes(dob)) {
          this.holidayInfo = `Your birthday falls on a public holiday: ${dob} `;
        } else {
          this.holidayInfo = `Your birthday (${dob}) does not fall on a public holiday.`;
        }

      })
      .catch(error => {
          this.errorMessage = 'An error occurred while retrieving/processing the data.';
      });
    
  }

  closeModal() {
    this.showModal = false;
  } 
  
}