public class CustomObjectBatchImportProcessor  implements IBatchImportProcessor{

    
    public void performImport( Id importId, String csvFileName, String objectName, Map < String, Integer > fieldNumberMap, String[] csvDataLines,
                              String operation,
                              Map< String, String > fieldMapping, List< String > matchKeys ){
        // handleImport(importId, csvFileName, objectName,fieldNumberMap,csvDataLines,operation,fieldMapping,matchKeys);//old code
        //QuableBatchImportProcessor queue=;  
        ID jobID = System.enqueueJob(new QuableBatchImportProcessor(importId, csvFileName, objectName,fieldNumberMap,csvDataLines,operation,fieldMapping,matchKeys)); 
        system.debug('quable'+jobID);                  
    }
    
    
    
    //@future//old code
    public static void handleImport( Id importId, String csvFileName, String objectName, Map < String, Integer > fieldNumberMap, String[] csvDataLines,
                              String operation,
                              Map< String, String > fieldMapping, List< String > matchKeys ){
        
        // SObject conObj;
    	// String csvDataAsString;
    	// String fieldValue;
    	// Integer fieldNumber;
        // String testStr;
        // String field;
        // Integer rowNumber = 1;
        // Integer objectIndex = 0;
        // Map<Integer, Integer> indexRowNumMap = new Map<Integer, Integer>();
        // system.debug('Entity - ' + objectName);
    	// List < SObject > objectList = new List < SObject > ();
		// Map < Integer, SObject > objectMap = new Map < Integer, SObject >();                                  
        // Map < Integer, String > resultMap = new Map < Integer, String >();
		// Map < String, Set<Object> > uniqueValueMap = new Map < String, Set<Object> >();                                  
        // for (Integer i = 1; i < csvDataLines.size(); i++) {
        //     rowNumber = i + 1;
        //     conObj = Schema.getGlobalDescribe().get(objectName).newSObject();
        //     String[] csvRecordData = HelperUtil.separateCommas(csvDataLines[i]);
        //     Set<String> fieldNames = fieldMapping.keySet();
        //     List<String> errorList = new List<String>();
        //     for (String columnName : fieldNames ) {
        //         String fieldName = fieldMapping.get(columnName);
                
        //         if ( fieldName == null || String.isEmpty(fieldName) ) {
        //             continue;
        //         }
        //         fieldNumber = fieldNumberMap.get(columnName);
        //         fieldValue = csvRecordData[fieldNumber];
        //         try{
        //             // ActualFeildBatch batchz=new ActualFeildBatch(objectName,fieldName,fieldValue);
        //             // Database.executeBatch(batchz, 1000);
        //             // idMap=batchz.getReturnValue();
        //             // System.debug('ID MAP RETURN'+idMap);

		// 			conObj.put( fieldName, HelperUtil.getActualFieldValue(objectName,fieldName,fieldValue) );
        //             if ( ! uniqueValueMap.containsKey(fieldName) ) {
        //                 uniqueValueMap.put(fieldName, new Set<Object>() );
        //             }
        //             uniqueValueMap.get(fieldName).add(HelperUtil.getActualFieldValue(objectName,fieldName,fieldValue) );
                    
        //         } catch(Exception ex){
        //             errorList.add(fieldName + ' - ' + ex.getMessage());
        //             System.debug('Field Name - ' + fieldName + ' - ' + ex.getMessage());
        //         }            
                
        //     }//for (String fieldName : fieldNames ) {
            
        //     if ( errorList.size() > 0 ) {
		// 		errorList.add(0,'Following Data errors are found.');
        //         resultMap.put( rowNumber, String.join(errorList, ' '));
        //     } else {
        //     	objectList.add(conObj);
        //         indexRowNumMap.put(objectIndex, rowNumber);
        //         objectIndex = objectIndex + 1;
        //         objectMap.put(rowNumber, conObj);
        //     }
           
        // } //for (Integer i = 1; i < csvDataLines.size(); i++) {//old code
                                  
		// System.debug('Valid Objects - '+objectList);                                  
		// System.debug('ErrorMap - ' + resultMap);
        // if(objectList.size() > 0){
        //     if ( 'Insert'.equalsIgnoreCase(operation) ) {
        //         System.debug('Creating Objects...');
        //         // old code
        //         //List<Database.SaveResult> saveResult=new List<Database.SaveResult>();
        //         //saveResult=batch.saveResult;
        //         //System.debug('saveresultmain'+saveResult);
        //         //resultMap.putAll(createObjects(objectList, indexRowNumMap));
        //         //new code
        //         InsertEventsBatch batch=new InsertEventsBatch(objectList, indexRowNumMap, csvFileName,importId,operation);
        //         Database.executeBatch(batch, 1000);
        //     } else {
        //         System.debug('Modifying Objects...');
        //         //old code
        //         // resultMap.putAll(modifyObjects(objectName, objectList, indexRowNumMap, operation, matchKeys, uniqueValueMap));
        //         //new code
                
        //         modifyObjects(objectName, objectList, indexRowNumMap, operation, matchKeys, uniqueValueMap,csvFileName,importId);
        //     }
        // }
        // else {
        //     errorHistory(csvFileName, resultMap, importId);
        // } //if(objectList.size() > 0){
        
            //HelperUtil.updateImportHistory(csvFileName, resultMap, importId);  //old code
            
            // new code
            ActualFeildBatch batchz=new ActualFeildBatch(importId, csvFileName, objectName,fieldNumberMap, csvDataLines, operation, fieldMapping, matchKeys);
            Database.executeBatch(batchz, 1000);
            //idMap=batchz.getReturnValue();
            //System.debug('ID MAP RETURN'+idMap);

		
    } //performImport
    
    //new code
    public static void errorHistory(String csvFileName, Map < Integer, String > resultMap,Id importId){
        HelperUtil.updateImportHistory(csvFileName, resultMap, importId);
    } 



    private static Map<Integer, String> createObjects(List<SObject> objectList, Map< Integer, Integer > indexRowNumMap){
        Map<Integer, String> resultMap = new Map<Integer, String>();
		//List< Database.SaveResult > saveResults = Database.insert(objectList, false);
      //  resultMap.putAll(handleResults(saveResult, indexRowNumMap));
        return resultMap;
    } //createObjects//old code
    
    
    
    public static void modifyObjects(String objectName, List<SObject> objectList,
                                              Map< Integer, Integer > indexRowNumMap,
                                              String operation,List< String > matchKeys,
                                             Map < String, Set<Object> > uniqueValueMap,String csvFileName,Id importId){
       Map<Integer, String> resultMap = new Map<Integer, String>();
       try {
                                                     
        
            List< SObject > validObjects = new List< SObject >();
            List< SObject > insertRecords = new List< SObject >();
            List< SObject > updateRecords = new List< SObject >();
    
            List<Database.SaveResult> insertResults = null;
            List<Database.SaveResult> updateResults = null;                                                         
            Database.SaveResult saveResult = null;
            Integer insertIndex = 0;
            Integer updateIndex = 0;
            Integer rowNumber = 0;
            Integer index = 0;
            Map<Integer, Integer> insertIndexRowNumMap = new Map<Integer, Integer>();                                                         
            Map<Integer, Integer> updateIndexRowNumMap = new Map<Integer, Integer>();                                                         
    
            List < String > keys = new List < String >();
            for ( String curKey : matchKeys ) {
                List<String> splitVal = curKey.split(',');
                keys.addAll(splitVal);
            }
            Integer keySize = keys.size();
            
            List<SObject> allObjects = getAllObjects(objectName, uniqueValueMap);
            Map<String, SObject> idMap = new Map<String, SObject>();
            String concatKeyValue = null;

           

            for ( SObject curObject : allObjects ) {
                concatKeyValue = '';
                List<String> keyValues = new List<String>();
                for ( String curKey : keys ) {
                    //keyValues.add( String.valueOf( curObject.get( curKey.trim() ) ) ); 
                    Object actualVal =  HelperUtil.getActualFieldValue( objectName,curKey.trim(),String.valueOf( curObject.get( curKey.trim() ) ) );
                    keyValues.add( String.valueOf( actualVal ).toLowerCase().trim() );      
                } //for ( String curKey : keys ) {
                concatKeyValue = String.join(keyValues, ';');
                idMap.put(concatKeyValue, curObject);
            } //for ( SObject curObject : allObjects ) 
            
            system.debug('idMap - ' + idMap);
            system.debug('allObjects - ' + allObjects);
            
            for ( SObject curObject : objectList ) {
                rowNumber = indexRowNumMap.get(index);
                concatKeyValue = '';
                List<String> keyValues = new List<String>();
                for ( String curKey : keys ) {
                    keyValues.add( String.valueOf( curObject.get( curKey.trim() ) ).toLowerCase().trim() );        
                } //for
                concatKeyValue = String.join(keyValues, ';');
                system.debug('concatKeyValue - ' + concatKeyValue);
                if ( idMap.containsKey(concatKeyValue) ) {
                    SObject existingObject = idMap.get(concatKeyValue);
                    curObject.Id = existingObject.Id;
                    updateRecords.add(curObject);
                    updateIndexRowNumMap.put(updateIndex, rowNumber);
                    updateIndex = updateIndex + 1;
                }else{
                    if ( 'update'.equalsIgnoreCase(operation) ) {
                        resultMap.put(rowNumber, 'Record not found to Update');
                        errorHistory(csvFileName, resultMap, importId);
                    } else {
                        insertRecords.add(curObject);
                        insertIndexRowNumMap.put(insertIndex, rowNumber);
                        insertIndex = insertIndex + 1;                        
                    } //if ( 'update'.equals(operation) ) {
                } //if ( idMap.containsKey(concatKeyValue) ) {
                index = index + 1;
            } //for ( SObject curObject : objectList ) {
    
            
            if ( insertRecords.size() > 0 ) {
                // insertResults = Database.insert(insertRecords, false);
                // system.debug('Insert Save results - ' + insertResults);
                // resultMap.putAll(handleResults(insertResults, insertIndexRowNumMap));
                InsertEventsBatch batch=new InsertEventsBatch(insertRecords, indexRowNumMap, csvFileName,importId,operation);
                Database.executeBatch(batch, 1000);
            } //if ( insertRecords.size() > 0 ) {
                                                     
            if ( updateRecords.size() > 0 ) {
                // updateResults = Database.update(updateRecords, false);
                // system.debug('Update Save results - ' + updateResults);
                // resultMap.putAll(handleResults(updateResults, updateIndexRowNumMap));
                InsertEventsBatch batch=new InsertEventsBatch(updateRecords, indexRowNumMap, csvFileName,importId,operation);
                Database.executeBatch(batch, 1000);
            } //if ( updateRecords.size() > 0 ) {                                                
        
                                                     
            system.debug('resultMap - ' + resultMap);
        } catch(Exception ex){
            system.debug('Exception - ' + ex.getMessage() + ' Line Number - ' + ex.getLineNumber());
        }
       // return resultMap;
    } //modifyObjects
    
    
    
    public static Map<Integer, String> handleResults(List<Database.SaveResult> saveResults, Map<Integer, Integer> indexRowNumMap){
        
        Map<Integer, String> resultMap = new Map<Integer, String>();
        
        Integer curRow = 0;
        for ( Integer curIndex = 0; curIndex < saveResults.size() ; curIndex++ ){
            try {
                
                Database.SaveResult curResult = saveResults.get(curIndex);
                curRow = indexRowNumMap.get(curIndex);
                if ( curResult.isSuccess() ) {
                    resultMap.put(curRow, 'Success');
                }else{
                    List<Database.Error> errors = curResult.getErrors();
                    List<String> errorText = new List<String>();
                    for ( Database.Error curError : errors ) {
                        if (curError instanceof Database.DuplicateError) {
         					Database.DuplicateError duplicateError = (Database.DuplicateError)curError;
                            errorText.add('The following error has occurred.');                   
                        	errorText.add(duplicateError.getStatusCode() + ': ' + duplicateError.getMessage());
                        	errorText.add('Fields that affected this error: ' + duplicateError.getFields());
                        } else {
                            errorText.add('The following error has occurred.');                   
                        	errorText.add(curError.getStatusCode() + ': ' + curError.getMessage());
                        	errorText.add('Fields that affected this error: ' + curError.getFields());
                        }
                    } //for ( Database.Error curError : errors ) {
                    resultMap.put(curRow, String.join(errorText, ' '));
                } //if ( curResult.isSuccess() ) {
			}catch( Exception ex){
                resultMap.put(curRow, ex.getMessage());
            } //try
        } //for ( Integer curRow : objectMap.keySet() )
        return resultMap;
        
    } //handleResults
    
    
    private static List<SObject> getAllObjects(String objectName, Map<String, Set<Object>> valueMap){
        List<SObject> allObjects = new List<SObject>();
        Integer iter = 1;
        Integer keySize = valueMap.size();
        List< String > queryWords = new List< String > ();
        for ( String curKey : valueMap.keySet() ) {
            Set<Object> values = valueMap.get(curKey);
            Schema.DisplayType displayType = HelperUtil.getDisplayType(objectName, curKey.trim());
            boolean appendQuotes = HelperUtil.appendQuotes(displayType);
            String escapedString = '';
            Integer valueSize = values.size();
            String strVal = '';
            List<String>  curfieldValues = new List<String>();
            for ( Object curValue : values ) {
                strVal = String.valueOf( curValue );

                if ( displayType.equals(Schema.DisplayType.DATE) ) {
                    strVal = strVal.removeEnd(' 00:00:00');
                }
                
                if ( String.isEmpty(strVal) ) {
                    continue;
                }
                if ( appendQuotes ){
                    curfieldValues.add('\'' + String.escapeSingleQuotes( strVal.escapeJava() ) + '\'');
                } else {
                    curfieldValues.add( strVal );
                } //if ( appendQuotes ){                
                
            } //for ( Object curValue : values ) {
            
            if ( curfieldValues.size() > 0 ) {
                queryWords.add(curKey.trim());
                queryWords.add('IN (');
                queryWords.add(String.join(curfieldValues, ','));
                queryWords.add(')');
            } //if ( curfieldValues.size() > 0 ) {
            
            if( iter < keySize ) {
                queryWords.add('OR');
            } //if( iter < keySize ) {
            iter = iter + 1;
        } //for
        String conditionQuery = String.join(queryWords, ' ');
        system.debug('conditionQuery - ' + conditionQuery);
        String selectFields = '';
        if ( valueMap.keySet().contains('Id') ) {
            selectFields = String.join( new List<String>(valueMap.keySet()), ',');
        } else {
            selectFields = 'Id,' + String.join( new List<String>(valueMap.keySet()), ',');
        } //if
        
        String countQuery = 'SELECT count() FROM ' + objectName + ' WHERE ' + conditionQuery;
		String selectQuery = 'SELECT ' + selectFields +' FROM ' + objectName + ' WHERE ' + conditionQuery;
        Integer totalObjectsCount = Database.countQuery(countQuery);
        system.debug('selectQuery - ' + selectQuery);
        system.debug('countQuery - ' + countQuery);
        boolean continueLooping = true;
        Integer curOffset = 0;        
        while(continueLooping){
            String curQuery = selectQuery + ' LIMIT ' + HelperUtil.SOQL_MAX_QUERY_LIMIT + ' OFFSET ' + curOffset;
            List<SObject> curSelectList = Database.query(curQuery);
            curOffset = curOffset + curSelectList.size();
            allObjects.addAll(curSelectList);
            if ( allObjects.size() == totalObjectsCount ){
                continueLooping = false;
            } //if ( allObjects.size() == totalCount ){
        } //while(continueLooping){                                                       
        
        return allObjects;
    } //private List<Event__c> getAllEvents(List<Integer> yearList){
    
}