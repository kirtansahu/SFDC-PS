public class AC_AgreementController {
    @AuraEnabled
    public static String getCarform(String recordId) {
        String str = '';
        String queueName ='';
        CARFORM__c objCARFORM =  [SELECT Id,Status__c,OwnerId,Submitted_for_Approval__c,Customer_Relationship_Type__c FROM CARFORM__c WHERE Id =: recordId];
        if(objCARFORM.Status__c =='Draft' || objCARFORM.Status__c == 'Submitted to Manager' || objCARFORM.Status__c == 'Completed' || 
           objCARFORM.Submitted_for_Approval__c == false){
                queueName =''; 
           }else{
                queueName = [SELECT id,name FROM Group WHERE Id =: objCARFORM.OwnerId].Name;
           }
        if(objCARFORM.Customer_Relationship_Type__c == 'Associate'){
            str = System.Label.AC_AgreementAssociateError;
            return str;
        }else if(queueName != 'AMN - AC - CLM'){           
            str = System.Label.AC_AgreementCLMQueueError;
            return str;            
        }
        
        if(str == ''){
            Apttus__Wizard2__c objWizard = new Apttus__Wizard2__c();
            objWizard.Name = 'Michelin CLM / Agreement System';
            objWizard.Apttus__WizardDesignId__c = System.Label.APTS_CARFOROM_WizardID;
            objWizard.Apttus__ContextId__c = objCARFORM.Id;
            objWizard.Apttus__ContextType__c = 'CARFORM__c';
            objWizard.Apttus__Status__c = 'In Progress';   
            try{
                insert objWizard;
                if(objWizard != null){
                    str = objWizard.Id;
                }
                return str;
            }catch(exception e){
                system.debug('errMsg--->'+e.getMessage()+e.getLineNumber()+e.getCause());
                
            }
        }
        return str;     
    }   
}