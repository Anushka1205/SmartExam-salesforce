@IsTest
private class QuestionServiceTest {

    @TestSetup
    static void setupData() {

        Question__c q1 = new Question__c(
            Question_Text__c = 'What is Salesforce?',
            Question_Type__c = 'Single Choice',
            Marks__c = 5,
            Active__c = true
        );

        Question__c q2 = new Question__c(
            Question_Text__c = 'Select CRM Platforms',
            Question_Type__c = 'Multiple Choice',
            Marks__c = 5,
            Active__c = true
        );

        insert new List<Question__c>{ q1, q2 };

        insert new List<Answer__c>{

            new Answer__c(
                Question__c = q1.Id,
                Answer_Text__c = 'CRM',
                Is_Correct__c = true
            ),

            new Answer__c(
                Question__c = q1.Id,
                Answer_Text__c = 'Compiler',
                Is_Correct__c = false
            ),

            new Answer__c(
                Question__c = q2.Id,
                Answer_Text__c = 'Salesforce',
                Is_Correct__c = true
            ),

            new Answer__c(
                Question__c = q2.Id,
                Answer_Text__c = 'HubSpot',
                Is_Correct__c = true
            ),

            new Answer__c(
                Question__c = q2.Id,
                Answer_Text__c = 'Photoshop',
                Is_Correct__c = false
            )
        };
    }

    @IsTest
    static void testGetActiveQuestions() {

        Test.startTest();

        List<Question__c> questions =
            QuestionService.getActiveQuestions();

        Test.stopTest();

        System.assertEquals(2, questions.size());
    }

    @IsTest
    static void testGetActiveQuestionCount() {

        Test.startTest();

        Integer count =
            QuestionService.getActiveQuestionCount();

        Test.stopTest();

        System.assertEquals(2, count);
    }

    @IsTest
    static void testGetQuestionAnswers() {

        Set<Id> questionIds = new Set<Id>();

        for (Question__c q : [
            SELECT Id
            FROM Question__c
        ]) {
            questionIds.add(q.Id);
        }

        Test.startTest();

        List<Answer__c> answers =
            QuestionService.getQuestionAnswers(questionIds);

        Test.stopTest();

        System.assertEquals(5, answers.size());
    }

    @IsTest
    static void testValidateQuestionsHaveAnswers() {

        Test.startTest();

        QuestionService.validateQuestionsHaveAnswers();

        Test.stopTest();

        System.assert(true);
    }

    @IsTest
    static void testGetQuestionsWithAnswers() {

        Test.startTest();

        List<QuestionService.QuestionWrapper> result =
            QuestionService.getQuestionsWithAnswers();

        Test.stopTest();

        System.assertEquals(2, result.size());

        for (QuestionService.QuestionWrapper question : result) {

            System.assert(question.answers.size() > 0);

        }
    }

}