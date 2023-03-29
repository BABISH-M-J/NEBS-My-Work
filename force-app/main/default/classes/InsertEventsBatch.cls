public class InsertEventsBatch implements Database.Batchable<SObject>,Database.Stateful {
        // public List< sObject > obj= new List< sObject >();
        // public List<Database.SaveResult> saveResult=new List<Database.SaveResult>();
        // String keyData='';
        // public InsertEventsBatch(List<sObject> getval, string key ) {
        //     this.obj=getval;
        //     System.debug('object1'+this.obj);
        //    this.keyData=key;
        // }
        
        // public List<sObject> start(Database.BatchableContext BC) {
        //     CustomObjectBatchImportProcessor custObjBatchImp = new CustomObjectBatchImportProcessor();
        //     custObjBatchImp.performImport(importId, csvFileName, objectName, fieldNumberMap, csvDataLines, operation, fieldMapping, matchKeys);

        //     //System.debug('object'+obj);
        //     System.debug('object this'+this.obj);
        //    // return Database.getQueryLocator(BatchImportController.fetchCSVFilData(csv_str));
        //    return this.obj;
           
        // }
        
        // public void execute(Database.BatchableContext BC, List<sObject> scope) {
            
        //     System.debug('BC'+BC);
        //     System.debug('scope'+scope);
        //     if(keyData=='insert'){
        //         saveResult.addAll(Database.insert(scope, false));
        //     }
        //     else if (keyData=='update') {
        //         saveResult.addAll(Database.update(scope, false));
        //     }
        //     else {
        //         throw new AuraHandledException('Unsupported operation: ' + keyData);
        //     }
        //    // return saveResult;
        // }
        
      
        // public void finish(Database.BatchableContext BC) {
        // }
        // public List<Database.SaveResult> retunMethod()
        // {
        //     return saveResult;
        // }



       /* private Id importId;
        private String csvFileName;
        private String objectName;
        private Map<String, Integer> fieldNumberMap;
        private String[] csvDataLines;
        private String operation;
        private Map<String, String> fieldMapping;
        private List<String> matchKeys;

        private Map<Integer,String> resultMap=new Map<Integer,String>();
        public Integer count;
    
        public InsertEventsBatch(Id importId, String csvFileName, String objectName, Map<String, Integer> fieldNumberMap, 
                            String[] csvDataLines, String operation, Map<String, String> fieldMapping, List<String> matchKeys) {
            this.importId = importId;
            this.csvFileName = csvFileName;
            this.objectName = objectName;
            this.fieldNumberMap = fieldNumberMap;
            this.csvDataLines = csvDataLines;
            this.operation = operation;
            this.fieldMapping = fieldMapping;
            this.matchKeys = matchKeys;
            count=0;
        }
    
        public List<String> start(Database.BatchableContext bc) {
            //List<String> word_List = Arrays.asList(this.csvDataLines); 
           // List<Object> objectList = new ArrayList<Object>(word_List);
           system.debug('this.csvDataLines'+this.csvDataLines);
            return this.csvDataLines;
        }
    
        public void execute(Database.BatchableContext bc, List<String> csvDataLine) {
            count++;
            System.debug('total_count'+count);
       
            this.resultmap.putAll(CustomObjectBatchImportProcessor.handleImport(this.importId, this.csvFileName, this.objectName,this.fieldNumberMap, csvDataLine, this.operation, this.fieldMapping, this.matchKeys,count));
           
            
            System.debug('resultmap1234====='+this.resultMap);
            System.debug('resultmap1234====='+this.resultMap);
            if (this.resultMap.size()>0) {
                HelperUtil.updateImportHistory(this.csvFileName, this.resultMap, this.importId);
            }
        }
    
        public void finish(Database.BatchableContext bc) {
            System.debug('resultmap====='+this.resultMap);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'babish@pfdigital.in'};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Batch Apex Job is done');
            mail.setPlainTextBody('Total' +'  '+ count +'  '+ 'Records updated sucessfully');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
             
            // Your code to run at the end of the batch
        }*/



        public List< sObject > obj= new List< sObject >();
        public List<Database.SaveResult> saveResult=new List<Database.SaveResult>();
        Map<Integer, Integer> indexRowNumMap = new Map<Integer, Integer>();
        Map < Integer, String > resultMap = new Map < Integer, String >();
        String csvFileName;
        Id importId;
        String operation;

        public InsertEventsBatch(List<sObject> getval,  Map<Integer, Integer> indexRowNumMap, String csvFileName,Id importId, String operation) {
             this.obj=getval;
             this.indexRowNumMap=indexRowNumMap;
             this.csvFileName=csvFileName;
             this.importId=importId;
             this.operation=operation;
             
            System.debug('object1'+this.obj);
           
        }
        public List<sObject> start(Database.BatchableContext BC) {

               return this.obj;
               
            }
            public void execute(Database.BatchableContext BC, List<sObject> scope) {
                        try {
                            if ('Insert'.equalsIgnoreCase(this.operation)) {
                                this.saveResult.addAll(Database.insert(scope, false));
                            }
                             else {
                                this.saveResult.addAll(Database.update(scope, false));
                             }   
                           System.debug('saveResult'+saveResult);
                           System.debug('saveResult_count'+saveResult.size());
                        } catch (Exception e) {
                            System.debug('Exception while inserting=='+e);
                        }
                   

                }
                public void finish(Database.BatchableContext BC) {
                   resultMap.putAll( CustomObjectBatchImportProcessor.handleResults(this.saveResult,this.indexRowNumMap));
                   system.debug('resultMap From InsertEvent class=='+ resultMap);
                   HelperUtil.updateImportHistory(csvFileName, resultMap, importId);
                //    system.debug('resultMap From InsertEvent class==', resultMap);
                   
                    }
                   
             
    }