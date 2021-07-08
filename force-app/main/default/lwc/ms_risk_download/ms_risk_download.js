import { LightningElement, track } from 'lwc';
import getRisks from '@salesforce/apex/MS_NewFile.getRisks';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Ms_risk_download extends LightningElement {

    @track isModalOpen = false;

    handleClick(event) {
        console.log('button clicked');
        this.isModalOpen = true;
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

    submitDetails() {
        getRisks()
            .then(result => {
                console.log(result);
                let downloadElement = document.createElement('a');
                downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(result);
                downloadElement.target = '_self';
                downloadElement.download = 'ms_risk_export.csv';
                downloadElement.click(); 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Risks have been downloaded according to MetricStream format',
                        variant: 'Success',
                    }),
                );
            })
            .catch(error => {
                console.log(error);
            })
        this.closeModal();
    }

    exportCSVFile(headers, totalData, fileTitle){
        if(!totalData || !totalData.length){
            return null
        }
        const jsonObject = JSON.stringify(totalData)
        const result = convertToCSV(jsonObject, headers)
        if(result === null) return
        const blob = new Blob([result])
        const exportedFilename = fileTitle ? fileTitle+'.csv' :'export.csv'
        if(navigator.msSaveBlob){
            navigator.msSaveBlob(blob, exportedFilename)
        } else if (navigator.userAgent.match(/iPhone|iPad|iPod/i)){
            const link = window.document.createElement('a')
            link.href='data:text/csv;charset=utf-8,' + encodeURI(result);
            link.target="_blank"
            link.download=exportedFilename
            link.click()
        } else {
            const link = document.createElement("a")
            if(link.download !== undefined){
                const url = URL.createObjectURL(blob)
                link.setAttribute("href", url)
                link.setAttribute("download", exportedFilename)
                link.style.visibility='hidden'
                document.body.appendChild(link)
                link.click()
                document.body.removeChild(link)
            }
        }
    }
}