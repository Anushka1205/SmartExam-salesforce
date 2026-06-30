public with sharing class QuestionService {

    /*
     * Wrapper class for Answer
     */
    public class AnswerWrapper {
        @AuraEnabled public Id answerId;
        @AuraEnabled public String answerText;
    }

    /*
     * Wrapper class for Question
     */
    public class QuestionWrapper {
        @AuraEnabled public Id questionId;
        @AuraEnabled public String questionText;
        @AuraEnabled public String questionType;
        @AuraEnabled public Decimal marks;
        @AuraEnabled public List<AnswerWrapper> answers;
    }

    // Returns all active questions
    public static List<Question__c> getActiveQuestions() {

        return [
            SELECT Id,
                   Name,
                   Question_Text__c,
                   Question_Type__c,
                   Marks__c
            FROM Question__c
            WHERE Active__c = true
        ];
    }

    // Returns all answers for the given questions
    public static List<Answer__c> getQuestionAnswers(Set<Id> questionIds) {

        return [
            SELECT Id,
                   Answer_Text__c,
                   Is_Correct__c,
                   Question__c
            FROM Answer__c
            WHERE Question__c IN :questionIds
        ];
    }

    // Returns the number of active questions
    public static Integer getActiveQuestionCount() {

        return [
            SELECT COUNT()
            FROM Question__c
            WHERE Active__c = true
        ];
    }

    // Validates that every active question has at least one answer
    public static void validateQuestionsHaveAnswers() {

        List<Question__c> activeQuestions = getActiveQuestions();

        if (activeQuestions.isEmpty()) {
            throw new AuraHandledException('No active questions found.');
        }

        Set<Id> questionIds = new Set<Id>();

        for (Question__c question : activeQuestions) {
            questionIds.add(question.Id);
        }

        List<Answer__c> answers = getQuestionAnswers(questionIds);

        Map<Id, Integer> answerCountMap = new Map<Id, Integer>();

        for (Answer__c answer : answers) {

            if (!answerCountMap.containsKey(answer.Question__c)) {
                answerCountMap.put(answer.Question__c, 0);
            }

            answerCountMap.put(
                answer.Question__c,
                answerCountMap.get(answer.Question__c) + 1
            );
        }

        for (Question__c question : activeQuestions) {

            if (!answerCountMap.containsKey(question.Id)) {

                throw new AuraHandledException(
                    'Question "' +
                    question.Question_Text__c +
                    '" has no answer options.'
                );
            }
        }
    }

    /*
     * Returns Questions along with their Answers
     */
    @AuraEnabled(cacheable=true)
    public static List<QuestionWrapper> getQuestionsWithAnswers() {

        List<Question__c> questions = getActiveQuestions();

        Set<Id> questionIds = new Set<Id>();

        for (Question__c q : questions) {
            questionIds.add(q.Id);
        }

        List<Answer__c> answers = getQuestionAnswers(questionIds);

        Map<Id, List<AnswerWrapper>> answerMap =
            new Map<Id, List<AnswerWrapper>>();

        for (Answer__c ans : answers) {

            if (!answerMap.containsKey(ans.Question__c)) {
                answerMap.put(ans.Question__c, new List<AnswerWrapper>());
            }

            AnswerWrapper aw = new AnswerWrapper();
            aw.answerId = ans.Id;
            aw.answerText = ans.Answer_Text__c;

            answerMap.get(ans.Question__c).add(aw);
        }

        List<QuestionWrapper> result =
            new List<QuestionWrapper>();

        for (Question__c q : questions) {

            QuestionWrapper qw = new QuestionWrapper();

            qw.questionId = q.Id;
            qw.questionText = q.Question_Text__c;
            qw.questionType = q.Question_Type__c;
            qw.marks = q.Marks__c;

            if (answerMap.containsKey(q.Id)) {
                qw.answers = answerMap.get(q.Id);
            } else {
                qw.answers = new List<AnswerWrapper>();
            }

            result.add(qw);
        }

        return result;
    }
}