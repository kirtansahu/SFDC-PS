public without sharing class AC_AccountMaintenanceController{
    
    @AuraEnabled
    public static wrapperAC retrieveAccountMaintenanceUtilities(string strACAction,Id accountId, string strTypesOfCustomer){
        List<wrapperACUtilities> lstwrapperACUtilities = new List<wrapperACUtilities>();
        for(AC_AccountMaintenanceUtility__mdt objAMU : [SELECT Sort_Order__c,Reference_Object_API__c,Lookup_Filter__c,Account_Field_Label__c,Account_Field_API__c,Account_Maintenance_Type__c,CARFORM_Field_Label__c,
                                                        CARFORM_Field_API__c,CARFORM_LineItem_Field_API__c,Data_Type__c,Display_field_for_Account_Type__c,Types_Of_Customer__c,Field_Location__c,
                                                        Help_Text__c FROM AC_AccountMaintenanceUtility__mdt 
                                                        Where Account_Maintenance_Type__c =: strACAction Order By Sort_Order__c]){
                                                            List<string> lstPickListValues = new List<string>();
                                                            Carform__c objCarform = new Carform__c();
                                                            if(objAMU.Data_Type__c == 'Picklist' || objAMU.Data_Type__c == 'Picklist (Multi-Select)'){
                                                                if(objAMU.CARFORM_Field_API__c == 'Bibexpress__c' || objAMU.CARFORM_Field_API__c == 'BibFill__c'){
                                                                    lstPickListValues.add('Yes');
                                                                    lstPickListValues.add('No');
                                                                }
                                                                else{
                                                                    lstPickListValues.addAll((MichelinUtils.getPicklistValueMap('Carform__c',objAMU.CARFORM_Field_API__c)).keyset());
                                                                }
                                                            }
                                                            
                                                            wrapperACUtilities objwrapperACUtilities = new wrapperACUtilities(objAMU.Account_Field_Label__c,
                                                                                                                              objAMU.Account_Field_API__c,
                                                                                                                              objAMU.CARFORM_Field_Label__c,
                                                                                                                              objAMU.CARFORM_Field_API__c,
                                                                                                                              objAMU.CARFORM_LineItem_Field_API__c,
                                                                                                                              objAMU.Data_Type__c,
                                                                                                                              lstPickListValues,
                                                                                                                              objAMU.Sort_Order__c,
                                                                                                                              objAMU.Reference_Object_API__c,
                                                                                                                              objAMU.Lookup_Filter__c,
                                                                                                                              objAMU.Display_field_for_Account_Type__c,
                                                                                                                              objAMU.Help_Text__c,
                                                                                                                              objAMU.Types_Of_Customer__c,
                                                                                                                              objAMU.Field_Location__c,
                                                                                                                              null
                                                                                                                             );
                                                            
                                                            if(strACAction == 'Add Ship To' || strACAction == 'Modify Ship To'){
                                                                Account acc = [Select Id,Commercial_Relation__c,Customer_Relationship_Type__c From Account Where Id = : accountId];
                                                                String strAccCustRelType = (strTypesOfCustomer == 'NAFA' || strTypesOfCustomer == 'Government' || strTypesOfCustomer == 'MFS') ? 'Direct' : ((acc.Customer_Relationship_Type__c != null) ? acc.Customer_Relationship_Type__c : 'Direct');

                                                                if(strAccCustRelType  == objAMU.Display_field_for_Account_Type__c || objAMU.Display_field_for_Account_Type__c == 'Both'){
                                                                    if(objAMU.Types_Of_Customer__c !=  null){
                                                                        String[] arrTypesOfCustomer = objAMU.Types_Of_Customer__c.split(',');
                                                                        boolean blnTOCMatch = false;
                                                                        for(string typesOfCustomer : arrTypesOfCustomer){
                                                                            if(typesOfCustomer == strTypesOfCustomer){
                                                                                blnTOCMatch = true;
                                                                            }
                                                                        }
                                                                        if(blnTOCMatch){
                                                                            lstwrapperACUtilities.add(objwrapperACUtilities); 
                                                                        }
                                                                    }
                                                                    else{
                                                                        lstwrapperACUtilities.add(objwrapperACUtilities);
                                                                    }
                                                                }
                                                            }
                                                            else{
                                                                lstwrapperACUtilities.add(objwrapperACUtilities);
                                                            }
                                                            //mapOfAccFieldsAndUtility.put(objAMU.Account_Field_API__c,objAMU);
                                                        }
        
        AC_RecordType_Maintenance_Type_Mapping__mdt objMaintenanceMapping = new AC_RecordType_Maintenance_Type_Mapping__mdt();
        objMaintenanceMapping = [Select Left_Legend__c,Right_Legend__c,Header_Message__c From AC_RecordType_Maintenance_Type_Mapping__mdt Where Account_Maintenance_Type__c = : strACAction];
        wrapperAC objWrapperAC = new wrapperAC(lstwrapperACUtilities,objMaintenanceMapping.Left_Legend__c,objMaintenanceMapping.Right_Legend__c,objMaintenanceMapping.Header_Message__c);
        
        return objWrapperAC;
    }
    
    @AuraEnabled
    public static CARFORM__c getPrimaryDetailsFromId(Id carformId){
        CARFORM__c objCarform = [SELECT ID,Name,Status__c,Initial_Submitter__c,Form_Owner_For_Workflows__c,Requesting_For__c,Requesting_For__r.Name,Account_Maintenance_Type__c,expected_Annual_Increase__c,Type_of_Customer__c,Customer_Relationship_Type__c,Account__r.Name,Account__r.Commercial_Relation__c,Account__r.Customer_Relationship_Type__c,Account__r.Ultimate_Parent_Reference__c,Account__r.Phone,Account__r.Fax,Account__r.Legacy_Id__c,
                                 Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode,Account__r.BillingCountry, Account__r.BillingAddress, Account__r.Hold_Status__c,
                                 Account__r.ShippingStreet,Account__r.ShippingCity,Account__r.ShippingState,Account__r.ShippingPostalCode,Account__r.ShippingCountry,Account__r.ShippingAddress,Account__r.Shipping_Country_Name__c,
                                 Submitted_for_Approval__c,Account__c,Account__r.Doing_business_as__c,Account__r.ParentId,Account__r.Parent.PSD_Primary_Servicing_Distributor__c,Account__r.PSD_Primary_Servicing_Distributor__c,Account__r.PSD_Servicing_WH_ST__c,Account__r.Does_customer_wish_to_parti_in_ePartner__c,Account__r.ePartner_Start_Date__c,
                                 Delete_Reason__c,comments__c,Initial_Submitter__r.Name,Account__r.Sales_Agreement_Codes__c,Account__r.Location_Type__c,Account__r.Customer_s_Number_with_PSD__c,Account__r.RecordType.DeveloperName,Account__r.ShipToExternalID__c,Special_Instructions__c,Bill_To_DBA_Name__c From CARFORM__c Where Id= :carformId];
        
        if(objCarform.Account__r.PSD_Primary_Servicing_Distributor__c != null){
            Account objPSD = getPSDAccountByLegacyId(objCarform.Account__r.PSD_Primary_Servicing_Distributor__c);
            if(objPSD != null){
                objCarform.Account__r.PSD_Primary_Servicing_Distributor__c = objPSD.Name + '$#' + objCarform.Account__r.PSD_Primary_Servicing_Distributor__c  + '$#' + objPSD.Id;
            }
        }
        
        if(objCarform.Account__r.PSD_Servicing_WH_ST__c!= null){
            Account objPSD = new Account();
            if(objCarform.Account__r.ParentId != null) {
                if(objCarform.Account__r.Parent.PSD_Primary_Servicing_Distributor__c != null) {
                    objPSD = getPSDAccountByLegacyId(objCarform.Account__r.Parent.PSD_Primary_Servicing_Distributor__c);
                }
            }
            Account objPSDST = getPSDAccountByLegacyId(objCarform.Account__r.PSD_Servicing_WH_ST__c);
            if(objPSDST != null){
                if(objPSD != null) {
                    objCarform.Account__r.PSD_Primary_Servicing_Distributor__c = objPSD.Name + '$#' + objCarform.Account__r.Parent.PSD_Primary_Servicing_Distributor__c + '$#' + objPSD.Id; 
                }
                objCarform.Account__r.Segmentation_Distribution_Channel__c = objCarform.Account__r.PSD_Servicing_WH_ST__c;
                objCarform.Account__r.PSD_Servicing_WH_ST__c = objPSDST.Name + '$#' + objPSDST.Id;
            }
        }
        
        objCarform.put('Volume__c',JSON.serialize((MichelinUtils.getPicklistValueMap('Carform__c','Type_of_Customer__c')).keyset()));
        system.debug(' objCarform ::::: ' + objCarform);
        return objCarform;
    }
    
    @AuraEnabled
    public static Account getAccountById(Id accountId){
        Account objAccount = [SELECT Id, Name, RecordTypeId,RecordType.DeveloperName,Ultimate_Parent_Reference__c,Legacy_Id__c, Commercial_Relation__c,Customer_Relationship_Type__c, Hold_Status__c,
                              PSD_Primary_Servicing_Distributor__c,PSD_Servicing_WH_ST__c,ParentId,Parent.PSD_Primary_Servicing_Distributor__c,
                              BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingLatitude, 
                              BillingLongitude, BillingGeocodeAccuracy, BillingAddress, Doing_business_as__c,
                              ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingLatitude, 
                              ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress,Shipping_Country_Name__c, Phone,Fax,
                              Does_customer_wish_to_parti_in_ePartner__c,ePartner_Start_Date__c,Sales_Agreement_Codes__c,Location_Type__c,
                              Customer_s_Number_with_PSD__c,ShipToExternalID__c,AMN_Customer_Type_Conversion__c,Credit_Manager__c,Parent.Credit_Manager__c FROM Account Where Id =: accountId];
        
        if(objAccount.PSD_Primary_Servicing_Distributor__c != null){
            Account objPSD = getPSDAccountByLegacyId(objAccount.PSD_Primary_Servicing_Distributor__c);
            if(objPSD != null){
                objAccount.PSD_Primary_Servicing_Distributor__c = objPSD.Name + '$#' + objAccount.PSD_Primary_Servicing_Distributor__c + '$#' + objPSD.Id;
            }
        }
        
        if(objAccount.PSD_Servicing_WH_ST__c!= null){
            Account objPSD = new Account();
            if(objAccount.ParentId != null) {
                if(objAccount.Parent.PSD_Primary_Servicing_Distributor__c != null) {
                    objPSD = getPSDAccountByLegacyId(objAccount.Parent.PSD_Primary_Servicing_Distributor__c);
                }
            }
            Account objPSDST = getPSDAccountByLegacyId(objAccount.PSD_Servicing_WH_ST__c);
            
            if(objPSDST != null){
                if(objPSD != null) {
                    objAccount.PSD_Primary_Servicing_Distributor__c = objPSD.Name + '$#' + objAccount.Parent.PSD_Primary_Servicing_Distributor__c + '$#' + objPSD.Id;
                    
                }
                objAccount.Segmentation_Distribution_Channel__c = objAccount.PSD_Servicing_WH_ST__c;
                objAccount.PSD_Servicing_WH_ST__c = objPSDST.Name + '$#' + objPSDST.Id;
            }
        }
        return objAccount;
    }
    
    @AuraEnabled
    public static List<Account> getSelectedAccountsByCarformId(Id carformId){
        Set<Id> setOfAccId = new Set<Id>();
        
        for(CARFORM_Line_Item__c objCarformLineItem : [Select Id,Account__c From CARFORM_Line_Item__c Where CARFORM__c =: carformId]){
            setOfAccId.add(objCarformLineItem.Account__c);
        }
        system.debug('setOfAccId ::: ' + setOfAccId);
        return [SELECT Id, Name, RecordTypeId,Ultimate_Parent_Reference__c,
                Legacy_Id__c,Hold_Code_Status__c,Hold_Status__c,ShippingStreet,ShippingCity,ShippingState 
                FROM Account Where RecordType.DeveloperName = 'Delivery_Group' And Id in : setOfAccId];
    }
    
    @AuraEnabled
    public static List<CARFORM_Line_Item__c> getShipTosByCarformId(Id carformId){
        return [Select Id,Name,CARFORM__r.Owner.Name,Account__c,Is_the_Customer_Tax_Exempt__c,Tax_Exemption_Same_as_Bill_To__c,
                Account__r.Name,Shipping_Legal_Name_of_the_Company__c,Doing_Business_As_DBA__c,Primary_Phone__c,
                Physical_Address__c,Physical_City__c,Physical_State_Province__c,
                Zip_Postal_code__c, Physical_County__c,Physical_Country__c,Location_Type__c,Legacy_ID__c,Store_Plant_Code__c 
                From CARFORM_Line_Item__c Where CARFORM__c =: carformId];
    }
    
    @AuraEnabled
    public static List<Account> getRelatedAccountsById(string ultimateParent){
        
        List <Account> returnList = new List <Account> ();
        
        String sQuery =  'SELECT Id, Name, RecordTypeId,Ultimate_Parent_Reference__c, ';
        sQuery += 'Legacy_Id__c,Hold_Code_Status__c,Hold_Status__c,ShippingStreet,ShippingCity, ';
        sQuery += 'ShippingState FROM Account ';
        sQuery += 'Where RecordType.DeveloperName = \'Delivery_Group\'';
        
        if(ultimateParent != null && ultimateParent != ''){
            sQuery += ' And ' + ultimateParent;
        }
        
        sQuery += ' order by createdDate DESC';
        
        system.debug('sQuery ::: ' + sQuery);
        
        List <Account> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add((Account)obj);
        }
        
        return returnList;
    }
    
    @AuraEnabled
    public static carformDataWrapper getCARFORMDetails(Id carformId,List<string> lstFields,Id carformLineItemId,Map<string,string> mapOfFields,Map<String,String> mapOfDataTypes){
        string strCARFORMFields = '';
        
        for(string strField : lstFields){
            strCARFORMFields += ' ,' + strField;
        }
        
        if(carformLineItemId != null){
            string strCARFORMLineItemFields = '';
            
            for(string strField : mapOfFields.values()){
                if(strField != null && strField != ''){
                    strCARFORMLineItemFields += ' ,' + strField;
                }
            }
            
            CARFORM_Line_Item__c objCLI = Database.query('SELECT Id,Account__c,CARFORM__r.Legacy_ID__c, Name ' + strCARFORMLineItemFields + ' From CARFORM_Line_Item__c Where Id =: carformLineItemId');
            
            Map<Object,Object> objCARFORM = new Map<Object,Object>();
            
            objCARFORM.put('Legacy_ID__c',objCLI.CARFORM__r.Legacy_ID__c);
            for(string strCF : mapOfFields.keyset()){
                if(mapOfFields.get(strCF) != null && mapOfFields.get(strCF) != ''){
                    if(mapOfDataTypes.get(strCF) == 'Text' || mapOfDataTypes.get(strCF) == 'Textarea' || mapOfDataTypes.get(strCF) == 'Picklist'
                       || mapOfDataTypes.get(strCF) == 'Picklist (Multi-Select)' || mapOfDataTypes.get(strCF) == 'Phone' || mapOfDataTypes.get(strCF) == 'Email'){
                           objCARFORM.put(strCF,string.valueOf(objCLI.get(mapOfFields.get(strCF))));   
                       }
                    else if(mapOfDataTypes.get(strCF) == 'Date' || mapOfDataTypes.get(strCF) == 'Date/Time'){
                        objCARFORM.put(strCF,Date.valueOf(objCLI.get(mapOfFields.get(strCF))));   
                    }
                    else if(mapOfDataTypes.get(strCF) == 'Number' || mapOfDataTypes.get(strCF) == 'Currency'){
                        objCARFORM.put(strCF,Double.valueOf(objCLI.get(mapOfFields.get(strCF))));
                    }
                    else if(mapOfDataTypes.get(strCF) == 'Checkbox'){
                        objCARFORM.put(strCF,Boolean.valueOf(objCLI.get(mapOfFields.get(strCF))));
                    }
                    else if(mapOfDataTypes.get(strCF) == 'Reference'){
                        String sField = mapOfFields.get(strCF);
                        if(sField.indexof('.') != -1){
                            String sFieldSub1 = sField.SubString(0,sField.indexof('.'));
                            String sFieldSub2 = sField.SubString(sField.indexof('.') + 1,sField.Length());
                            
                            sObject objRef = objCLI.getSObject(sFieldSub1);
                            String sValue = (objRef != null) ? string.valueOf(objRef.get(sFieldSub2)) : '';
                            
                            objCARFORM.put(strCF,sValue);   
                        }
                        else{
                            objCARFORM.put(strCF,String.valueOf(objCLI.get(mapOfFields.get(strCF))));
                        }
                    }
                }
            }
            carformDataWrapper objcarformDataWrapper = new carformDataWrapper(null,objCARFORM);            
            return objcarformDataWrapper;
        }
        else{
            CARFORM__c objCARFORM = Database.Query('SELECT Id,Account__c, Name,AMN_Updated_Fields__c,Account_Maintenance_Type__c ' + strCARFORMFields + ' From CARFORM__c Where Id =: carformId');
            carformDataWrapper objcarformDataWrapper = new carformDataWrapper(objCARFORM,null);
            return objcarformDataWrapper;
        }
    }
    
    @AuraEnabled
    public static carformWrapper insertAccountMaintenanceRecord(CARFORM__c objCarform){
        try{
            if(objCarform.Parent_CARFORM__c == null){
                objCarform.RecordTypeId = AC_CARFORMUtils.ACCOUNT_MAINTENANCE_TYPE_ID;
                if(objCarform.AMN_Updated_Fields__c != null && objCarform.AMN_Updated_Fields__c != ''){
                    objCarform.AMN_Updated_Fields__c = objCarform.AMN_Updated_Fields__c.removeEnd(',');
                }
                upsert objCarform;
            }
            return new carformWrapper(objCarform,'');
        }
        catch (DmlException de) {
            Integer numErrors = de.getNumDml();
            string dmlExcep  = '';
            for( Integer i = 0; i < numErrors; i ++ ) {
                dmlExcep += de.getDmlFieldNames(i) + ' - ' + de.getDmlMessage(i) + '\n'; 
            }
            return new carformWrapper(null,dmlExcep);
            
        }    
        catch(Exception ex){
            system.debug('Error ::: ' + ex.getMessage());
            return new carformWrapper(null,system.Label.AC_SomethingWrongError);
        }
    }
    
    @AuraEnabled
    public static string insertRelatedCarformLineItem(CARFORM__c objCarform,List<CARFORM_Line_Item__c> lstCarformLineItem){
        try{
            string cliRecTypeId = '';
            if(objCarform.Account_Maintenance_Type__c == 'Add Ship To' || objCarform.Account_Maintenance_Type__c == 'Modify Ship To'){
                if(objCarform.Customer_Relationship_Type__c == 'Associate'){
                    cliRecTypeId = AC_CARFORMUtils.AC_ASSOCIATE_SHIP_TO_TYPE_ID;
                }
                else if(objCarform.Customer_Relationship_Type__c == 'Direct'){
                    cliRecTypeId = AC_CARFORMUtils.AC_DIRECT_SHIP_TO_TYPE_ID;
                }
                else{
                    cliRecTypeId = AC_CARFORMUtils.AC_ACCOUNT_MAINTENANCE_TYPE_ID_CLI;
                }
            }
            else{
                cliRecTypeId = AC_CARFORMUtils.AC_ACCOUNT_MAINTENANCE_TYPE_ID_CLI;
            }
            
            Set<String> setOfCarformIdAccId = new Set<String>();
            List<CARFORM_Line_Item__c> lstExistingCLI = new List<CARFORM_Line_Item__c>();
            lstExistingCLI = [Select Id,Name,CARFORM__c,Account__c From CARFORM_Line_Item__c Where CARFORM__c = : objCarform.Id];
            
            List<CARFORM_Line_Item__c> lstNewCarformLineItem = new List<CARFORM_Line_Item__c>();
            for(CARFORM_Line_Item__c objCLI : lstExistingCLI){
                setOfCarformIdAccId.add(objCLI.Account__c);
                if(objCarform.Account_Maintenance_Type__c == 'Modify Ship To'){
                    Id CLI_ID = objCLI.Id;
                    objCLI = lstCarformLineItem[0];
                    objCLI.Id = CLI_ID;
                    lstNewCarformLineItem.add(objCLI);
                }
            }
            for(CARFORM_Line_Item__c objCARFORMLI : lstCarformLineItem){
                objCARFORMLI.RecordTypeId = cliRecTypeId;
                if(objCarform.Account_Maintenance_Type__c == 'Add Ship To'){
                    lstNewCarformLineItem.add(objCARFORMLI);
                }
                else{
                    if(setOfCarformIdAccId != null && setOfCarformIdAccId.size() > 0){
                        if(!setOfCarformIdAccId.contains(objCARFORMLI.Account__c)){
                            lstNewCarformLineItem.add(objCARFORMLI);
                        }
                    }
                    else{
                        lstNewCarformLineItem.add(objCARFORMLI);
                    }
                }
            }
            upsert lstNewCarformLineItem;
            
            return system.Label.AC_Success;
        }
        catch (DmlException de) {
            Integer numErrors = de.getNumDml();
            string dmlExcep  = '';
            for( Integer i = 0; i < numErrors; i ++ ) {
                dmlExcep += de.getDmlFieldNames(i) + ' - ' + de.getDmlMessage(i) + '\n'; 
            }
            system.debug('Error ::: ' + dmlExcep);
            return dmlExcep;
        }    
        catch(Exception ex){
            system.debug('Error ::: ' + ex.getMessage());
            return system.Label.AC_SomethingWrongError;
        }
    }
    
    @AuraEnabled
    public static void deleteCarformLineItem(Id carformId,Id accountId){
        
        string strQuery = 'Select Id,Name From CARFORM_Line_Item__c Where CARFORM__c =: carformId';
        if(accountId != null){
            strQuery += ' AND Account__c = : accountId';
        }
        
        system.debug('strQuery ::: ' + strQuery);
        
        List<CARFORM_Line_Item__c> lstCARFORMLineItems = Database.Query(strQuery);
        
        if(lstCARFORMLineItems.size() > 0){
            delete lstCARFORMLineItems;
        }
    }
    
    @AuraEnabled
    public static void deleteShipToById(Id cliId){
        delete [Select Id From CARFORM_Line_Item__c Where Id =: cliId];
    }
    
    @AuraEnabled
    public static String runValidation(Id recId) {
        String strError = '';
        try{
            
            List<Carform__c > lstCarform = [SELECT Id,Name,Status__c,Submitted_for_Approval__c,RecordTypeId,OwnerId,Account_Maintenance_Type__c From CARFORM__c Where Id =: recId];
            
            if(lstCarform[0].Submitted_for_Approval__c){
                return System.Label.AC_Record_Submitted_Error;   
            }
            
            if(lstCarform[0].Account_Maintenance_Type__c == 'Close Bill To'){
                Id OwnerId = lstCarform[0].OwnerId;
                User owner = [Select Id,ManagerId,Manager.IsActive From User Where Id =: OwnerId];
                
                if(owner.ManagerId == null || owner.Manager.IsActive == false){
                    return system.Label.AC_NoManagerToAssignError;
                }
            }            
            
            strError += AC_ValidateCARFORM.validateMaintenanceCARFORM(lstCarform);
            if(strError != ''){
                strError += + '\n';
            }
            strError += Boost_CarFormController.AC_ValidateAddress(recId,true,null,null);
            
            if(strError != ''){
                return strError;
            }
            
            if(lstCarform[0].Account_Maintenance_Type__c == 'Add Ship To'){
                List<CARFORM_Line_Item__c> ObjCLIList = [SELECT Id,Name,PSD_Warehouse__c,PSD_will_not_service_this_location__c From CARFORM_Line_Item__c where CARFORM__c =:recId];
                string psdWarehouse = '';
                for(CARFORM_Line_Item__c objCARFORMLI : ObjCLIList){                
                    if(objCARFORMLI.PSD_Warehouse__c != null && psdWarehouse == ''){
                        psdWarehouse = objCARFORMLI.PSD_Warehouse__c;
                    }   
                }
                if(psdWarehouse != null && psdWarehouse != ''){
                    List<CARFORM_Line_Item__c> ObjNewCLIList = new List<CARFORM_Line_Item__c>();
                    for(CARFORM_Line_Item__c objCARFORMLI : ObjCLIList){
                        if(objCARFORMLI.PSD_Warehouse__c == null){
                            objCARFORMLI.PSD_Warehouse__c = psdWarehouse;
                            ObjNewCLIList.add(objCARFORMLI);
                        }
                    }
                    if(!ObjNewCLIList.isEmpty()){
                        update ObjNewCLIList;
                    }
                }
                
            }
            
            
            lstCarform[0].Submitted_for_Approval__c = true;
            lstCarform[0].Submission_Date__c = system.today();
            
            update lstCarform;
            
        }
        catch (System.DmlException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                strError += e.getDmlMessage(i) + ', '; 
            }
        }
        catch(Exception ex){
            strError = System.Label.AC_Account_Maintenance_Exception;
            system.debug('Exception ::: ' + ex);
        }
        return strError;
    }
    
    @AuraEnabled
    public static List < String > getselectOptions(string strObject, string fld,string accountId) {
        
        List < String > allOpts = new list < String > ();
        
        
        if(accountId != ''){
            String accRecType = [Select RecordType.DeveloperName From Account Where Id = : accountId].RecordType.DeveloperName;
            Map<string,string> mapOfMapping = new Map<string,string>();
            for(AC_RecordType_Maintenance_Type_Mapping__mdt objMapping : [Select Account_Maintenance_Type__c,Applicable_RecordTypes_API__c,Left_Legend__c,Right_Legend__c From 
                                                                          AC_RecordType_Maintenance_Type_Mapping__mdt]){
                                                                              
                                                                              mapOfMapping.put(objMapping.Account_Maintenance_Type__c,objMapping.Applicable_RecordTypes_API__c);
                                                                          }
            
            for(string value : (MichelinUtils.getPicklistValueMap(strObject,fld)).keyset()){
                if(mapOfMapping.get(value) != null && mapOfMapping.get(value).split(',').contains(accRecType)){
                    allOpts.add(value);
                }
            }
        }
        else{
            allOpts.addAll((MichelinUtils.getPicklistValueMap(strObject,fld)).keyset());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
    
    @AuraEnabled
    public static List<PSD_Matrix__c> getPSDAccounts(string regionName){
        return [Select Id,Name,Legacy_Id__c From PSD_Matrix__c WHERE Country__c =: regionName And isActive__c = true Order By Name];
    }
    
    @AuraEnabled
    public static List<Account> getPSDWarehouseDetailsById(string psdAccountId,String filter){
        List<Account> PSDWareHouseList = new List<Account>();
        if(!String.IsBlank(psdAccountId) && filter != '' && filter != null){ 
            PSDWareHouseList= [Select Id,Name,ParentId,RecordType.DeveloperName,ShippingStreet,ShippingAddress,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Store_Id__c,Legacy_Id__c,RecordTypeName__c from Account WHERE  ParentId =: psdAccountId  AND RecordType.DeveloperName = 'Delivery_Group' AND Name LIKE: '%'+filter+'%'];
        }
        return PSDWareHouseList;
    }
    
    @AuraEnabled
    public static string reactivateCarformbyId(Id carformId) {
        try{
            CARFORM__c objCarform = [Select Id,Status__c From Carform__c Where Id = : carformId];
            objCarform.Status__c= 'Draft';
            update objCarform;
            return system.Label.AC_Success;
        }
        catch (DmlException de) {
            Integer numErrors = de.getNumDml();
            string dmlExcep  = '';
            for( Integer i = 0; i < numErrors; i ++ ) {
                dmlExcep += de.getDmlFieldNames(i) + ' - ' + de.getDmlMessage(i) + '\n'; 
            }
            system.debug('dmlExcep = ' + dmlExcep);
            return dmlExcep;
        }    
        catch(Exception ex){
            system.debug('Error ::: ' + ex.getMessage());
            return system.Label.AC_Something_Went_Wrong;
        }
    }
    
    
    @AuraEnabled
    public static String getCurrentLoggedInUser(){
        return [Select Name From User Where Id = : UserInfo.getUserId()].Name;
    }
    
    @AuraEnabled
    public static Account getPSDAccountByLegacyId(String strLegacyId) {
        if(strLegacyId != null && strLegacyId != ''){
            List<Account> lstAccounts = [SELECT Id, Name FROM Account WHERE Legacy_Id__c = :strLegacyId];
            system.debug('lstAccounts = ' + lstAccounts);
            if(lstAccounts.size() > 0){
                return lstAccounts[0];
            }
        }
        return null;
    }
    
    public class wrapperACUtilities{
        @AuraEnabled public string accfieldLabel{get;set;}
        @AuraEnabled public string accfieldAPIName{get;set;}
        @AuraEnabled public string fieldLabel{get;set;}
        @AuraEnabled public string fieldAPIName{get;set;}
        @AuraEnabled public string fieldCLIAPIName{get;set;}
        @AuraEnabled public string dataType{get;set;}
        @AuraEnabled public List<string> pickListValues{get;set;}
        @AuraEnabled public string referenceObject{get;set;}
        @AuraEnabled public string lookupFilter{get;set;}
        @AuraEnabled public integer sortorder{get;set;}
        @AuraEnabled public string accountType{get;set;}
        @AuraEnabled public string helpText{get;set;}
        @AuraEnabled public string typesOfCustomer{get;set;}
        @AuraEnabled public string fieldLocation{get;set;}
        @AuraEnabled public string value{get;set;}
        
        public wrapperACUtilities(string accfieldLabel,string accfieldAPIName,string fieldLabel,string fieldAPIName,string fieldCLIAPIName,string dataType,List<string> pickListValues,decimal sortorder,string referenceObject,string lookupFilter,string accountType,string helpText, string typesOfCustomer,string fieldLocation,string value){
            this.accfieldLabel = (accfieldLabel != null) ? accfieldLabel : '';
            this.accfieldAPIName = (accfieldAPIName != null) ? accfieldAPIName : '';
            this.fieldLabel = (fieldLabel != null) ? fieldLabel : '';
            this.fieldAPIName = (fieldAPIName != null) ? fieldAPIName : '';
            this.fieldCLIAPIName = (fieldCLIAPIName != null) ? fieldCLIAPIName : '';
            this.dataType = (dataType != null) ? dataType : '';
            this.pickListValues = (pickListValues != null) ? pickListValues : new List<string>();
            this.sortorder = (sortorder != null) ? integer.valueOf(sortorder) : 0;
            this.referenceObject = (referenceObject != null) ? referenceObject : '';
            this.lookupFilter = (lookupFilter != null) ? lookupFilter : '';
            this.accountType = (accountType != null) ? accountType : '';
            this.helpText = (helpText != null) ? helpText : '';
            this.typesOfCustomer = (typesOfCustomer != null) ? typesOfCustomer : '';
            this.fieldLocation = (fieldLocation != null) ? fieldLocation : '';
            this.value = (value != null) ? value : '';
        }
    }
    
    public class wrapperAC{
        @AuraEnabled public List<wrapperACUtilities> lstWrapperACUtilities{get;set;}
        @AuraEnabled public string leftLegend{get;set;}
        @AuraEnabled public string rightLegend{get;set;}
        @AuraEnabled public string headerMessage{get;set;}
        
        public wrapperAC(List<wrapperACUtilities> lstWrapperACUtilities,string leftLegend,string rightLegend,string headerMessage){
            this.lstWrapperACUtilities = lstWrapperACUtilities;
            this.leftLegend = (leftLegend != null) ? leftLegend : '';
            this.rightLegend = (rightLegend != null) ? rightLegend : '';
            this.headerMessage = (headerMessage != null) ? headerMessage : '';
        }
    }
    
    public class carformWrapper{
        @AuraEnabled public CARFORM__c objCarform{ get;set; }
        @AuraEnabled public String errorMessage{ get;set; }
        public carformWrapper(CARFORM__c objCarform,String errorMessage){
            this.objCarform = objCarform;
            this.errorMessage = errorMessage;
        }
    }
    
    public class carformDataWrapper{
        @AuraEnabled public CARFORM__c objCarform{ get;set; }
        @AuraEnabled public Object objData{ get;set; }
        public carformDataWrapper(CARFORM__c objCarform,Object objData){
            this.objCarform = objCarform;
            this.objData = objData;
        }
    }
}
