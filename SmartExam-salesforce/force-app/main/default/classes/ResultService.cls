public with sharing class ResultService {

    /*
     * Called when the student submits the exam.
     * Calculates the score and updates the exam attempt.
     */
    @AuraEnabled
    public static void submitExam(Id examAttemptId) {

        if (examAttemptId == null) {
            throw new AuraHandledException('Exam Attempt Id is required.');
        }

        Decimal score = calculateScore(examAttemptId);

        updateExamAttempt(examAttemptId, score);
    }

    /*
     * Calculates the student's score.
     */
    public static Decimal calculateScore(Id examAttemptId) {

        Decimal totalScore = 0;

        // Get all responses for this attempt
        List<Response__c> responses = [
            SELECT Id,
                   Question__c,
                   Answer__c
            FROM Response__c
            WHERE Exam_Attempt__c = :examAttemptId
              AND Is_Selected__c = true
        ];

        if (responses.isEmpty()) {
            return 0;
        }

        // Store selected answers by question
        Map<Id, Set<Id>> selectedAnswersMap = new Map<Id, Set<Id>>();

        for (Response__c response : responses) {

            if (!selectedAnswersMap.containsKey(response.Question__c)) {
                selectedAnswersMap.put(response.Question__c, new Set<Id>());
            }

            selectedAnswersMap.get(response.Question__c).add(response.Answer__c);
        }

        // Get all correct answers
        List<Answer__c> correctAnswers = [
            SELECT Id,
                   Question__c
            FROM Answer__c
            WHERE Is_Correct__c = true
              AND Question__c IN :selectedAnswersMap.keySet()
        ];

        // Store correct answers by question
        Map<Id, Set<Id>> correctAnswersMap = new Map<Id, Set<Id>>();

        for (Answer__c answer : correctAnswers) {

            if (!correctAnswersMap.containsKey(answer.Question__c)) {
                correctAnswersMap.put(answer.Question__c, new Set<Id>());
            }

            correctAnswersMap.get(answer.Question__c).add(answer.Id);
        }

        // Get question marks
        Map<Id, Question__c> questionMap = new Map<Id, Question__c>([
            SELECT Id,
                   Marks__c
            FROM Question__c
            WHERE Id IN :selectedAnswersMap.keySet()
        ]);

        // Compare selected vs correct answers
        for (Id questionId : selectedAnswersMap.keySet()) {

            Set<Id> selected = selectedAnswersMap.get(questionId);
            Set<Id> correct = correctAnswersMap.get(questionId);

            if (correct != null && selected.equals(correct)) {

                totalScore += questionMap.get(questionId).Marks__c;

            }
        }

        return totalScore;
    }

    /*
     * Updates the Exam Attempt after submission.
     */
    public static void updateExamAttempt(
        Id examAttemptId,
        Decimal score
    ) {

        Exam_Attempt__c attempt = [
            SELECT Id
            FROM Exam_Attempt__c
            WHERE Id = :examAttemptId
            LIMIT 1
        ];

        attempt.Score__c = score;
        attempt.End_Time__c = System.now();
        attempt.Status__c = 'Completed';

        update attempt;
    }

}