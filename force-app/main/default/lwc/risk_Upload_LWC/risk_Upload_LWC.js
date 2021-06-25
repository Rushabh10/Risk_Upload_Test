import csvFileRead from '@salesforce/apex/CSVFileRead.csvFileRead';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';
import sendEmailToController from '@salesforce/apex/CSVFileRead.sendEmailToController';
import getUserDetails from '@salesforce/apex/CSVFileRead.getUserDetails';
import Id from '@salesforce/user/Id';



export default class Risk_Upload_LWC extends LightningElement {
    @api myRecordId;
    @track data;
    @track error;
    @track docId;
    @track subject = 'Risk Upload Results';
    @track body = '';
    @track toSend; // remove before sharing
    userId = Id;
    @track csvAttach;
    @track isModalOpen = false;
    @track fileName;


    // function to get the email ID of the current user
    @wire(getUserDetails, {
        recId: '$userId'
    })
    wiredUser({
        error,
        data
    }) {
        if (data) {
            this.user = data;
            console.log(data.Email);
            this.toSend = data.Email;

        } else if (error) {
            this.error = error;
        }
    }

    get acceptedFormats() {
        return ['.csv'];
    }


    // function to send the email
    sendEmailAfterUpload() {
        //console.log(this.data);
        this.csvAttach = this.data;
        var currentdate = new Date(); 
        var datetime = currentdate.getDate() + "/"
                        + (currentdate.getMonth()+1)  + "/" 
                        + currentdate.getFullYear() + " @ "  
                        + currentdate.getHours() + ":"  
                        + currentdate.getMinutes();
        this.body += 'Risks uploaded. PFA the log. <br />';
        this.body += 'Updated at: ' + datetime; 
        console.log('In the email function');
        const mailContent = {body: this.body, toSend: this.toSend, subject: this.subject, csvAttach: this.csvAttach};
        sendEmailToController(mailContent)
            .then(() => {
                console.log('mail sent');
            })
            .catch(error => {
                console.log(error);
            })
    }

    // modal helpers
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    // function to show toast event upon completion
    submitDetails() {
        csvFileRead({contentDocumentId: this.docId})
        .then(result => {
            console.log(result);
            this.data = result;
            this.sendEmailAfterUpload();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Risks have been created according to CSV file. An email has been sent with futher details.',
                    variant: 'Success',
                }),
            );
        })
        .catch(error => {
            console.log("Error: ");
            console.log(error);
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: JSON.stringify(this.error),
                    variant: 'error',
                }),   
            )
        })
        this.isModalOpen = false;
    }

    // handle upload of the file
    handleUploadFinished(event) {
        // Get the list of uploaded files
        //var inputName = document.getElementById("form_cols");
        // console.log(inputName);
        const uploadedFiles = event.detail.files[0];
        console.log(uploadedFiles);
        this.docId = uploadedFiles.documentId;
        this.fileName = uploadedFiles.name;
        console.log(this.docId);
        this.isModalOpen = true;
    }
}