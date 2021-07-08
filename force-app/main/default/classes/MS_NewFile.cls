public with sharing class MS_NewFile {

    @AuraEnabled
    public static string getRisks(){
        List<Risk__c> riskData = [SELECT Name, Risk_Area__c, RecordTypeId, Short_Description__c, Additional_Description__c FROM Risk__c];
        String final_res = 'Upload Type,Approval Required,ID,Name,Description,Owner Organizations,Admin Owners,Level 1 Approver,Level 2 Approver,Restrict Access To,Valid From,Valid Until,Comments,Level,Parents,Categories,Type,Areas of Impact,Key Risk,Attach Files,Regions,Risk Events,Risk Owners,Corporate Values,Notes\n';
        
        Id zeroId = SObjectType.Risk__c.getRecordTypeInfosByDeveloperName().get('category').getRecordTypeId();
        Id oneId = SObjectType.Risk__c.getRecordTypeInfosByDeveloperName().get('level1').getRecordTypeId();
        Id twoId = SObjectType.Risk__c.getRecordTypeInfosByDeveloperName().get('level2').getRecordTypeId();

        for(Integer i=0; i<riskData.size(); i++) {
            String level = '';
            String parent = '';
            if(riskData[i].recordTypeId == zeroId || riskData[i].recordTypeId == oneId) {
                level = 'Level 1 (Risk Area)';
            }
            else {
                level = 'Level 2';
                List<Risk__c> parents = [SELECT Name FROM Risk__c WHERE Id = :riskData[i].Risk_Area__c];
                parent = parents[0].Name;
            }
            final_res += 'New,No,,'+riskData[i].Name+','+riskData[i].Short_Description__c+',ERM,,,,No Restriction,,,,'+level+','+parent+',Default Value,,,,,,,,,'+riskData[i].Additional_Description__c+'\n';
        }
        return final_res;
    }

    // apex method to create the csv and send email
    @AuraEnabled(cacheable=true)
    public static void sendEmailToController(String body, String toSend, String subject, String csvAttach){
        try{
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(csvAttach);
            string csvname = 'risk_export.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
    
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {toSend};
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setHtmlBody(body);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    // apex method to get user details
    @AuraEnabled(cacheable=true)
    public static User getUserDetails(String recId) {
        return  [Select Id , Name ,Email from User where Id =:recId];
    }

}
