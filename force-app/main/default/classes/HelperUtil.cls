public class HelperUtil {

    private static Map<String,Map<String, Schema.SObjectField>> FIELD_MAP = new Map<String, Map<String, Schema.SObjectField>>();
    
    public static Integer SOQL_MAX_QUERY_LIMIT = 50000;
    
    public static void loadFieldMap(String objectName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Schema.SObjectType eventSchema = schemaMap.get(objectName);
		FIELD_MAP.put( objectName, eventSchema.getDescribe().fields.getMap() );
    }
    
    public static Object getActualFieldValue(String objectName, String fieldName, String fieldValue){
        if ( ! FIELD_MAP.containsKey(objectName) ) {
			loadFieldMap(objectName);
        }

        Schema.SObjectField field = FIELD_MAP.get(objectName).get(fieldName);

        Schema.DisplayType dataType = field.getDescribe().getType();
        switch on dataType{
            when STRING{
               return fieldValue;
            }
            when DOUBLE{
                   return DOUBLE.valueOf(fieldValue);
            }
            when PHONE{
               return fieldValue;
            }
            when EMAIL{
               return fieldValue; 
            }
            when BOOLEAN{
                if ( 'Y'.equalsIgnoreCase(fieldValue) || '1'.equalsIgnoreCase(fieldValue) ) {
                    return true;
                }else if( 'N'.equalsIgnoreCase(fieldValue) || '0'.equalsIgnoreCase(fieldValue) ) {
                    return false;
                }else{
                	return Boolean.valueOf(fieldValue);    
                }
                
            }
            when DATE{
                return Date.valueOf(fieldValue);
            }
            when DATETIME{
                return DateTime.valueOf(fieldValue);
            }
        }
        return null;
    }
    
    
    public static boolean appendQuotes(Schema.DisplayType displayType){
        switch on displayType{
            when STRING{
               return true;
            }
            when DOUBLE{
               return false;
            }
            when PHONE{
               return true;
            }
            when EMAIL{
               return true;
            }
            when BOOLEAN{
                return false;                
            }
            when DATE{
                return false;
            }
            when DATETIME{
                return false;
            }
        } //switch
        return true;
    }//appendQuotes
    
    
    public static Schema.DisplayType getDisplayType(String objectName, String fieldName) {
        if ( ! FIELD_MAP.containsKey(objectName) ) {
			loadFieldMap(objectName);
        }
        return FIELD_MAP.get(objectName).get(fieldName).getDescribe().getType();
    }
    
    
    public static boolean isValidSalesforceId(String value){
        return Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( value ).matches();

    }
    
    public static Map<String,Schema.SObjectField> getFieldsMap(String objectName){
        if ( ! FIELD_MAP.containsKey(objectName) ) {
			loadFieldMap(objectName);
        }
        return FIELD_MAP.get(objectName);
    }
    
    public static String getAllFieldNames(String objectName){
        if ( ! FIELD_MAP.containsKey(objectName) ) {
			loadFieldMap(objectName);
        }
        Set<String> fieldNames = FIELD_MAP.get(objectName).keySet();
        return String.join(new List<String>(fieldNames), ',');
    }
    
    public static List<String> separateCommas(String csvLine){
        
        String prevLine = csvLine;
        Integer startIndex;
        Integer endIndex;
        List<String> results = new List<String>();
        while(csvLine.indexOf('"') > -1){
        
            if(startIndex == null){
                startIndex = csvLine.indexOf('"');
                csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
            }else{
                if(endIndex == null){
                    endIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                }
            }
            
            if(startIndex != null && endIndex != null){
                String sub = csvLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                startIndex = null;
                endIndex = null;
            }
        } //while(csvLine.indexOf('"') > -1){
        
        for(String column : csvLine.split(',')){
          column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',').trim();
          results.add(column);
        }
        
        
        return results;
    } //separateCommas
    
    
    public static String getFileNameWithoutExtension (String str) {
        // Handle null case specially.
        if (str == null) return null;

        // Get position of last '.'.
        Integer pos = str.lastIndexOf('.');

        // If there wasn't any '.' just return the string as is.
        if (pos == -1) return str;

        // Otherwise return the string, up to the dot.
        return str.substring(0, pos);
    }
    

    public static void updateImportHistory(String csvFileName, Map<Integer, String> resultMap, Id importId){
        String importFileName = HelperUtil.getFileNameWithoutExtension(csvFileName);                                  
		String logFileName = importFileName + '-Log.csv';
//		if ( ! Test.isRunningTest() ) {                                  
            List< String > resultList = new List< String >();
            resultList.add('RowNumber,"Error Message"');
            for ( Integer rowNum : resultMap.keySet() ) {
                String curRowResult = rowNum + ',"' + resultMap.get(rowNum) + '"';
                resultList.add(curRowResult);
            }             
		
            String logContent = String.join(resultList, '\n');
            Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(logContent);
            attachment.Name = logFileName;
            attachment.ParentId = importId;
                                      
            Import_History__c importHistory = new Import_History__c();
            importHistory.Id = importId;
            importHistory.Log_File_Name__c = logFileName; 
            importHistory.Status__c = 'Completed';
        
            Database.SaveResult result = Database.insert(attachment);
            importHistory.Log_File_Id__c = result.getId();
           	Database.SaveResult updateResult = Database.update(importHistory);
//        } //if ( Test.isRunningTest() ) {


    //sending email

    //ContentVersion contentVersion = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :attachment.ParentId];

    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();


email.setToAddresses(new String[] {'babish@pfdigital.in','joselin@pfdigital.in'});
email.setSubject('Bulk Import');
email.setPlainTextBody('Your Bulk File Import was completed Successfully...!');


Messaging.EmailFileAttachment fileAttachment = new Messaging.EmailFileAttachment();
fileAttachment.setFileName(attachment.Name);
fileAttachment.setBody(attachment.Body);
email.setFileAttachments(new Messaging.EmailFileAttachment[] {fileAttachment});


// Messaging.Attachment attachmentAttachment = new Messaging.Attachment();
// attachmentAttachment.setFileName(attachment.Name);
// attachmentAttachment.setBody(attachment.Body);
// email.setFileAttachments(new Messaging.Attachment[] {attachmentAttachment});

// Send the email
Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});


        
    }
    
    
    public static Messaging.SingleEmailMessage constructMailObject(String subject, String body, List<String> toAddresses,
        List<String> ccAddresses, String senderDisplayName){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // Step 2: Set list of people who should get the email
        mail.setToAddresses(toAddresses);
            
        // Step 3: Set who the email is sent from
        mail.setSenderDisplayName(senderDisplayName);
            
        // (Optional) Set list of people who should be CC'ed
        mail.setCcAddresses(ccAddresses);
           
        // Step 4. Set email contents - you can use variables!
        mail.setSubject(subject);
        mail.setHtmlBody(body);
            
        return mail;
    }
}