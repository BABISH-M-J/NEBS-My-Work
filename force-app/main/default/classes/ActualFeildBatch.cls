public with sharing class ActualFeildBatch implements Database.Batchable<String>,Database.Stateful {
        SObject conObj;
        //Integer i=rowNumber;
        String csvFileName;
        String objectName;
        Id importId;
    	String csvDataAsString;
        Map < String, Integer > fieldNumberMap=new Map < String, Integer > ();
    	String fieldValue;
    	Integer fieldNumber;
        String testStr;
        String field;
        Integer rowNumber = 0;
        Integer objectIndex = 0;
        Map<Integer, Integer> indexRowNumMap = new Map<Integer, Integer>();
    	List < SObject > objectList = new List < SObject > ();
		Map < Integer, SObject > objectMap = new Map < Integer, SObject >();                                  
        Map < Integer, String > resultMap = new Map < Integer, String >();
		Map < String, Set<Object> > uniqueValueMap = new Map < String, Set<Object> >(); 
        String[] csvDataLines; 
        String operation;   
        Map< String, String > fieldMapping=new Map< String, String > ();
        List<String> matchKeys=new List<String>();

    public ActualFeildBatch(Id importId, String csvFileName, String objectName, Map < String, Integer > fieldNumberMap, String[] csvDataLines,
    String operation,
    Map< String, String > fieldMapping, List< String > matchKeys ) {
        
        this.operation=operation;
        this.matchKeys=matchKeys;
        this.fieldMapping=fieldMapping;
        this.fieldNumberMap=fieldNumberMap;
        this.objectName=objectName;
        this.csvFileName=csvFileName;
        this.importId=importId;
        this.objectName=objectName;
        this.csvDataLines=csvDataLines;
    }

    public List<String> start(Database.BatchableContext BC) {
        return this.csvDataLines;
    }

    public void execute(Database.BatchableContext BC, List<String> scope) {
   
        for (Integer i = 0; i < scope.size(); i++) {
            this.rowNumber += 1;
            this.conObj = Schema.getGlobalDescribe().get(this.objectName).newSObject();
            String[] csvRecordData = HelperUtil.separateCommas(scope[i]);
            Set<String> fieldNames = this.fieldMapping.keySet();
            List<String> errorList = new List<String>();
            for (String columnName : fieldNames ) {
                String fieldName = this.fieldMapping.get(columnName);
                
                if ( fieldName == null || String.isEmpty(fieldName) ) {
                    continue;
                }
                this.fieldNumber = this.fieldNumberMap.get(columnName);
                this.fieldValue = csvRecordData[this.fieldNumber];
                try{
					this.conObj.put( fieldName, HelperUtil.getActualFieldValue(this.objectName,fieldName,this.fieldValue) );
                    if ( ! this.uniqueValueMap.containsKey(fieldName) ) {
                        this.uniqueValueMap.put(fieldName, new Set<Object>() );
                        
                    }
                    this.uniqueValueMap.get(fieldName).add(HelperUtil.getActualFieldValue(this.objectName,fieldName,this.fieldValue) );
                    //this.uniqueValueMap.putAll(uniqueValueMap1);

                    
                } catch(Exception ex){
                    errorList.add(fieldName + ' - ' + ex.getMessage());
                    System.debug('Field Name - ' + fieldName + ' - ' + ex.getMessage());
                }            
                
            }//for (String fieldName : fieldNames ) {
            
            if ( errorList.size() > 0 ) {
				errorList.add(0,'Following Data errors are found.');
                this.resultMap.put( this.rowNumber, String.join(errorList, ' '));
                //this.resultMap.putAll(resultMap1);
            } else {
            	//objectList1.add(this.conObj);
                system.debug('objectList before put Array =='+this.objectList);
                system.debug('objectList before put Array size =='+this.objectList.size());
                // Integer count;
                // for (count=1;count<=this.objectList.size();count++) {
                //     if (count ==objectList.size()) {
                //         system.debug('last object list =='+this.objectList.get(count));
                //     }
                // }
            	this.objectList.add(this.conObj);
                system.debug('objectList after put array =='+this.objectList);
                system.debug('objectList after put array sze =='+this.objectList.size());
                system.debug('indexRowNumMap before put Array =='+this.indexRowNumMap);
                system.debug('indexRowNumMap before put Array size =='+this.indexRowNumMap.size());
                this.indexRowNumMap.put(this.objectIndex, this.rowNumber);
                //this.indexRowNumMap.putAll(indexRowNumMap1);
                system.debug('indexRowNumMap after put array =='+this.indexRowNumMap);
                system.debug('indexRowNumMap after put array size =='+this.indexRowNumMap.size());
                this.objectIndex = this.objectIndex + 1;
                system.debug('conObj before put Array =='+this.conObj);
                system.debug('conObj before put Array size =='+this.conObj);
                this.objectMap.put(this.rowNumber, this.conObj);
                system.debug('conObj after put Array =='+this.conObj);
                //system.debug('conObj after put Array size =='+this.conObj.size());
                //this.objectMap.putAll(objectMap1);
            }
           
        }
    }
    public void finish(Database.BatchableContext BC) {
            System.debug('Actual feild fill completed');
            System.debug('Valid Objects - '+objectList);  
            System.debug('Valid Objects size - '+objectList.size());                                
		System.debug('ErrorMap - ' + this.resultMap);
        if(this.objectList.size() > 0){
            if ( 'Insert'.equalsIgnoreCase(this.operation) ) {
                System.debug('Creating Objects...');
                // old code
                //List<Database.SaveResult> saveResult=new List<Database.SaveResult>();
                //saveResult=batch.saveResult;
                //System.debug('saveresultmain'+saveResult);
                //resultMap.putAll(createObjects(objectList, indexRowNumMap));
                //new code
                InsertEventsBatch batch=new InsertEventsBatch(this.objectList, this.indexRowNumMap , this.csvFileName,this.importId,this.operation);
                Database.executeBatch(batch, 1000);
            } else {
                System.debug('Modifying Objects...');
                //old code
                // resultMap.putAll(modifyObjects(objectName, objectList, indexRowNumMap, operation, matchKeys, uniqueValueMap));
                //new code
                
                CustomObjectBatchImportProcessor.modifyObjects(this.objectName, this.objectList, this.indexRowNumMap, this.operation, this.matchKeys, this.uniqueValueMap,this.csvFileName,this.importId);
            }
        }
        else {
            CustomObjectBatchImportProcessor.errorHistory(this.csvFileName, this.resultMap, this.importId);
        }
           
            
    }
    
    
}