List<Question__c> questions = QuestionService.getActiveQuestions();

System.debug('Number of Active Questions: ' + questions.size());

for (Question__c question : questions) {
    System.debug(question.Question_Text__c);
}