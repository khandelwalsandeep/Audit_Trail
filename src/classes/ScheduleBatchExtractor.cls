global class ScheduleBatchExtractor implements Schedulable {
   global void execute(SchedulableContext SC) {
      database.executebatch (new BatchExtractor(),1) ;
   }
}