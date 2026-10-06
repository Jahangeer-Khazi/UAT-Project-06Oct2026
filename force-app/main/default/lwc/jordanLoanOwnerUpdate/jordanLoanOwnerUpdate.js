import { LightningElement,api } from 'lwc';
import updateQueueOwner from '@salesforce/apex/CustomEmailComposerController.updateQueueOwner';
import { RefreshEvent } from 'lightning/refresh'; 

export default class JordanLoanOwnerUpdate extends LightningElement {

    @api ownerQueue;
    @api recordId;

    labelText = "";
    msg = "";

    isButtonDisabled = true;
    isSuccess = false;
    isError = false;
    

    connectedCallback() {
        console.log("R ",this.recordId); 
    }
    renderedCallback(){
        this.labelText = "Confirm you want to reassign to " + this.ownerQueue;
        console.log("Record Id ",this.recordId);
    }


    handleCheckboxChange(event){
        this.isButtonDisabled = !event.target.checked;
    }

    handleSave(event){
        console.log("Saved.");

        this.isSuccess = false;
        this.isError = false;
        if(this.recordId){
            updateQueueOwner({ recordId:this.recordId, queueName:this.ownerQueue})
            .then((result)=>{

                if(result == 'success'){
                    this.msg = "Sucessfully referred to " + this.ownerQueue;
                    this.isSuccess = true;

                    setTimeout(()=>{
                        this.dispatchEvent(new RefreshEvent());
                    },500);
                }
                else {
                    this.msg = 'Error while updating the owner ' + result;
                    this.isError = true;
                }
                
            })
            .catch(error => {
                this.msg = 'Error while updating the owner ' + error.body.message;
                this.isError = true;
            });
        }        
    }
}