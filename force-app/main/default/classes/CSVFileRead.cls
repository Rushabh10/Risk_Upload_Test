public with sharing class CSVFileRead {

    // apex method to process the csv, create risk records and update the database
    @AuraEnabled
    public static String csvFileRead(Id contentDocumentId) {
        System.debug(contentDocumentId);
        String final_res = 'Name,Risk Area,Level,Short Description,Currency ISO Code,Risk Category Order,Active,Additional Description,Add,Status\n';
        list<String> results = new list<String>();
        Integer resultsAdded = 0;
        if(contentDocumentId != null) {
            ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =:contentDocumentId];
            list<String> csvRecordList = objVersion.VersionData.toString().split('\n');

            // Insert level 0 - Risk Category
            for(Integer i=1; i<csvRecordList.size(); i++) {
                list<String> csvRowData = csvRecordList[i].split(',');
                Integer numCols = csvRowData.size();
                if(numCols == 9 && csvRowData[8].toUpperCase().indexOf('YES') != -1) {
                    if(csvRowData[2] == '0') {
                        if(csvRowData[0] == '') {
                            String errorMes = 'Error on record ' + String.valueOf(i) + ': Name is a compulsory field';
                            //results.add(errorMes);
                            results.add('Error: No Name');
                            String temp = csvRecordList[i].replace('\n', '');
                            temp = temp.replace('\r', '');
                            final_res += temp;
                            final_res += ',Error: No Name\n';
                        }
                        else {
                                Risk__c riskObj = new Risk__c();
                                riskObj.Additional_Description__c = csvRowData[7];
                                riskObj.Name = csvRowData[0];
                                riskObj.Short_Description__c = csvRowData[3];
                                riskObj.Risk_Area__c = null;
                                riskObj.CurrencyIsoCode__c = csvRowData[4] == '' ? null : csvRowData[4];
                                riskObj.Risk_Category_Order__c = csvRowData[5] == '' ? null : Integer.valueOf(csvRowData[5]);
                                riskObj.isActive__c = csvRowData[6].toUpperCase() == 'YES' ? true : false;
                                Id recordTypeId = SObjectType.Risk__c.getRecordTypeInfosByDeveloperName().get('category').getRecordTypeId();
                                riskObj.RecordTypeId = recordTypeId;
                                List<Risk__c> existingRisk = [SELECT Id, Name, RecordTypeId FROM Risk__c WHERE Name=:csvRowData[0]];
                                if(existingRisk.size() != 0 && existingRisk[0].RecordTypeId == recordTypeId) {
                                    existingRisk[0].Additional_Description__c = csvRowData[7];
                                    existingRisk[0].Name = csvRowData[0];
                                    existingRisk[0].Short_Description__c = csvRowData[3];
                                    existingRisk[0].Risk_Area__c = null;
                                    existingRisk[0].RecordTypeId = recordTypeId;
                                    existingRisk[0].isActive__c = csvRowData[6].toUpperCase() == 'YES' ? true : false;
                                    existingRisk[0].CurrencyIsoCode__c = csvRowData[4] == '' ? null : csvRowData[4];
                                    existingRisk[0].Risk_Category_Order__c = csvRowData[5] == '' ? null : Integer.valueOf(csvRowData[5]);
                                    update existingRisk;
                                    results.add('Success');
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Success - updated\n';
                                }
                                else if(existingRisk.size() != 0)
                                {
                                    String errorMes = 'Error on record ' + String.valueOf(i) + ': Risk with this name already exists';
                                    //results.add(errorMes);
                                    results.add('Error: Record with this name already exists'); 
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Error: Record with this name already exists\n';                              
                                }
                                else {
                                    insert riskObj;
                                    //resultsAdded++;
                                    results.add('Success - inserted');
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Success - inserted\n';
                                }      
                        }
                    }
                    if(csvRowData[2] == '') {
                        String temp = csvRecordList[i].replace('\n', '');
                        temp = temp.replace('\r', '');
                        final_res += temp;
                        final_res += ',Error: No level given\n';  
                    }
                }
                else if(csvRowData[2] == '0') {
                    String errorMes = 'Error on record ' + String.valueOf(i) + ': CSV fields not filled correctly';
                    results.add(errorMes); 
                    csvRowData.add('Error: CSV fields filled incorrectly'); 
                    String temp = csvRecordList[i].replace('\n', '');
                    temp = temp.replace('\r', '');
                    final_res += temp;
                    if(csvRowData[8].toUpperCase().indexOf('YES') != -1) {
                        final_res += ',Error: CSV fields filled incorrectly\n'; 
                    }
                    else {
                        final_res += ', Passed\n';
                    }
                }
            }

            // Insert level 1 - Risk Area
            for(Integer i=1; i<csvRecordList.size(); i++) {
                list<String> csvRowData = csvRecordList[i].split(',');
                Integer numCols = csvRowData.size();
                if(numCols == 9 && csvRowData[8].toUpperCase().indexOf('YES') != -1) {
                    if(csvRowData[2] == '1') {
                        if(csvRowData[0] == '') {
                            String errorMes = 'Error on record ' + String.valueOf(i) + ': Name is a compulsory field';
                            results.add(errorMes);
                            csvRowData.add('Error: No Name');
                            String temp = csvRecordList[i].replace('\n', '');
                            temp = temp.replace('\r', '');
                            final_res += temp;
                            final_res += ',Error: No Name\n';
                        }
                        else {
                                Risk__c riskObj = new Risk__c();
                                riskObj.Additional_Description__c = csvRowData[7];
                                riskObj.Name = csvRowData[0];
                                riskObj.Short_Description__c = csvRowData[3];
                                riskObj.Risk_Area__c = null;
                                riskObj.CurrencyIsoCode__c = csvRowData[4] == '' ? null : csvRowData[4];
                                riskObj.Risk_Category_Order__c = csvRowData[5] == '' ? null : Integer.valueOf(csvRowData[5]);
                                riskObj.isActive__c = csvRowData[6].toUpperCase() == 'YES' ? true : false;
                                Id recordTypeId= SObjectType.Risk__c.getRecordTypeInfosByDeveloperName().get('level1').getRecordTypeId();
                                riskObj.RecordTypeId = recordTypeId;
                                List<Risk__c> existingRisk = [SELECT Id, Name, RecordTypeId FROM Risk__c WHERE Name=:csvRowData[0]];
                                if(existingRisk.size() != 0 && existingRisk[0].RecordTypeId == recordTypeId) {
                                    existingRisk[0].Additional_Description__c = csvRowData[7];
                                    existingRisk[0].Name = csvRowData[0];
                                    existingRisk[0].Short_Description__c = csvRowData[3];
                                    existingRisk[0].Risk_Area__c = null;
                                    existingRisk[0].RecordTypeId = recordTypeId;
                                    existingRisk[0].isActive__c = csvRowData[6].toUpperCase() == 'YES' ? true : false;
                                    existingRisk[0].CurrencyIsoCode__c = csvRowData[4] == '' ? null : csvRowData[4];
                                    existingRisk[0].Risk_Category_Order__c = csvRowData[5] == '' ? null : Integer.valueOf(csvRowData[5]);
                                    update existingRisk;
                                    results.add('Success');
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Success - updated\n';
                                }
                                else if(existingRisk.size() != 0)
                                {
                                    String errorMes = 'Error on record ' + String.valueOf(i) + ': Risk with this name already exists';
                                    //results.add(errorMes);
                                    results.add('Error: Record with this name already exists'); 
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Error: Record with this name already exists\n';                              
                                }
                                else {
                                    insert riskObj;
                                    resultsAdded++;
                                    csvRowData.add('Success');
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Success - inserted\n';
                                }        
                        }
                    }
                }
                else if(csvRowData[2] == '1') {
                    String errorMes = 'Error on record ' + String.valueOf(i) + ': CSV fields not filled correctly';
                    results.add(errorMes);  
                    String temp = csvRecordList[i].replace('\n', '');
                    temp = temp.replace('\r', '');
                    final_res += temp;
                    if(csvRowData[8].toUpperCase().indexOf('YES') != -1) {
                        final_res += ',Error: CSV fields filled incorrectly\n'; 
                    }
                    else {
                        final_res += ', Passed\n';
                    } 
                }
            }
            
            // Insert level 2 - Obstacle
            for(Integer i=1; i<csvRecordList.size(); i++) {
                list<String> csvRowData = csvRecordList[i].split(',');
                Integer numCols = csvRowData.size();
                if(numCols == 9 && csvRowData[8].toUpperCase().indexOf('YES') != -1) {
                    if(csvRowData[2] == '2') {
                        if(csvRowData[0] == '') {
                            String errorMes = 'Error on record ' + String.valueOf(i) + ': Name is a compulsory field';
                            results.add(errorMes);
                            csvRowData.add('Error: No Name');
                            String temp = csvRecordList[i].replace('\n', '');
                            temp = temp.replace('\r', '');
                            final_res += temp;
                            final_res += ',Error: No Name\n';
                        }
                        else if(csvRowData[1] == '') {
                            String temp = csvRecordList[i].replace('\n', '');
                            temp = temp.replace('\r', '');
                            final_res += temp;
                            final_res += ',Error: No Risk Area provided\n';  
                        }
                        else {
                            Risk__c riskObj = new Risk__c();
                            riskObj.Additional_Description__c = csvRowData[7];
                            riskObj.Name = csvRowData[0];
                            riskObj.Short_Description__c = csvRowData[3];
                            riskObj.CurrencyIsoCode__c = csvRowData[4] == '' ? null : csvRowData[4];
                            riskObj.Risk_Category_Order__c = csvRowData[5] == '' ? null : Integer.valueOf(csvRowData[5]);
                            riskObj.isActive__c = csvRowData[6].toUpperCase() == 'YES' ? true : false;
                            Id recordTypeId= SObjectType.Risk__c.getRecordTypeInfosByDeveloperName().get('level2').getRecordTypeId();
                            riskObj.RecordTypeId = recordTypeId;
                            Integer updated = 0;
                            if(csvRowData[1] != '') {
                                String parentName = csvRowData[1];
                                List<Risk__c> existingRisk = [SELECT Id, Name, RecordTypeId FROM Risk__c WHERE Name=:csvRowData[0]];
                                List<Risk__c> parentRisk = [SELECT Id, Name, RecordTypeId FROM Risk__c WHERE Name=:parentName];
                                if(existingRisk.size() != 0 && existingRisk[0].RecordTypeId == recordTypeId) {
                                    existingRisk[0].Additional_Description__c = csvRowData[7];
                                    existingRisk[0].Name = csvRowData[0];
                                    existingRisk[0].Short_Description__c = csvRowData[3];
                                    Id parentId = parentRisk[0].Id;
                                    riskObj.Risk_Area__c = parentId;
                                    existingRisk[0].RecordTypeId = recordTypeId;
                                    existingRisk[0].isActive__c = csvRowData[6].toUpperCase() == 'YES' ? true : false;
                                    existingRisk[0].CurrencyIsoCode__c = csvRowData[4] == '' ? null : csvRowData[4];
                                    existingRisk[0].Risk_Category_Order__c = csvRowData[5] == '' ? null : Integer.valueOf(csvRowData[5]);
                                    update existingRisk;
                                    results.add('Success');
                                    updated = 1;
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Success - updated\n';
                                }
                                else if(existingRisk.size() != 0)
                                {
                                    String errorMes = 'Error on record ' + String.valueOf(i) + ': Risk with this name already exists';
                                    //results.add(errorMes);
                                    results.add('Error: Record with this name already exists'); 
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Error: Record with this name already exists\n';                              
                                }
                                if(parentRisk.size() == 0) {
                                    String errMes = 'Error on record ' + String.valueOf(i) + ': Risk Area ' + parentName + ' does not exist';
                                    results.add(errMes);
                                    String temp = csvRecordList[i].replace('\n', '');
                                    temp = temp.replace('\r', '');
                                    final_res += temp;
                                    final_res += ',Error: Risk Area does not exist\n'; 
                                }
                                else {
                                    Id parentId = parentRisk[0].Id;
                                    riskObj.Risk_Area__c = parentId;
                                    //List<Risk__c> existingRisk = [SELECT Id, Name FROM Risk__c WHERE Name=:csvRowData[0]];
                                    if(existingRisk.size() != 0 && updated == 0)
                                    {
                                        String errorMes = 'Error on record ' + String.valueOf(i) + ': Risk with this name already exists';
                                        results.add(errorMes);  
                                        //csvRowData.add('Error: Record with this name already exists');   
                                        String temp = csvRecordList[i].replace('\n', '');
                                        temp = temp.replace('\r', '');
                                        final_res += temp;
                                        final_res += ',Error: Record with this name already exists\n';                            
                                    }
                                    else if(existingRisk.size() == 0){
                                        insert riskObj;
                                        resultsAdded++;
                                        csvRowData.add('Success');
                                        String temp = csvRecordList[i].replace('\n', '');
                                        temp = temp.replace('\r', '');
                                        final_res += temp;
                                        final_res += ',Success - inserted\n';
                                    }
                                }
                            }
                        }
                    }
                }
                else if(csvRowData[2] == '2') {
                    String errorMes = 'Error on record ' + String.valueOf(i) + ': CSV fields not filled correctly';
                    results.add(errorMes);  
                    String temp = csvRecordList[i].replace('\n', '');
                    temp = temp.replace('\r', '');
                    final_res += temp;
                    if(csvRowData[8].toUpperCase().indexOf('YES') != -1) {
                        final_res += ',Error: CSV fields filled incorrectly\n'; 
                    }
                    else {
                        final_res += ', Passed\n';
                    }
                }
            }
        }
        results.add(string.valueOf(resultsAdded));
        return final_res;
    }

    // apex method to create the csv and send email
    @AuraEnabled(cacheable=true)
    public static void sendEmailToController(String body, String toSend, String subject, String csvAttach){
        try{
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(csvAttach);
            string csvname = 'log.csv';
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