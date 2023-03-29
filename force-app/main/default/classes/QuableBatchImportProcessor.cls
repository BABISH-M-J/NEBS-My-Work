public with sharing class QuableBatchImportProcessor implements Queueable {

        private Id importId;
        private String csvFileName;
        private String objectName;
        private Map<String, Integer> fieldNumberMap;
        private String[] csvDataLines;
        private String operation;
        private Map<String, String> fieldMapping;
        private List<String> matchKeys;

    public QuableBatchImportProcessor(Id importId, String csvFileName, String objectName, Map<String, Integer> fieldNumberMap, 
    String[] csvDataLines, String operation, Map<String, String> fieldMapping, List<String> matchKeys) {
            this.importId = importId;
            this.csvFileName = csvFileName;
            this.objectName = objectName;
            this.fieldNumberMap = fieldNumberMap;
            this.csvDataLines = csvDataLines;
            this.operation = operation;
            this.fieldMapping = fieldMapping;
            this.matchKeys = matchKeys;
    }
    public void execute(QueueableContext context) {
        CustomObjectBatchImportProcessor.handleImport(this.importId, this.csvFileName, this.objectName, this.fieldNumberMap, this.csvDataLines, this.operation, this.fieldMapping, this.matchKeys);       
    }
}