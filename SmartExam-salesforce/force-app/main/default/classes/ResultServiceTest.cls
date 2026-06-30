@IsTest
private class ResultServiceTest {

    @TestSetup
    static void setupData() {

        // Create Exam Configuration
        Exam_Config__c examConfig = new Exam_Config__c(
            Name = 'Mock Exam',
            Duration_Minutes__c = 60,
            Number_of_Questions__c = 1,
            Passing_Percentage__c = 50,
            Active__c = true
        );
        insert examConfig;

        // Create Question
        Question__c question = new Question__c(
            Question_Text__c = 'What is Salesforce?',
            Question_Type__c = 'Single Choice',
            Marks__c = 5,
            Active__c = true
        );
        insert question;

        // Create Answers
        Answer__c correctAnswer = new Answer__c(
            Question__c = question.Id,
            Answer_Text__c = 'CRM',
            Is_Correct__c = true
        );

        Answer__c wrongAnswer = new Answer__c(
            Question__c = question.Id,
            Answer_Text__c = 'Compiler',
            Is_Correct__c = false
        );

        insert new List<Answer__c>{
            correctAnswer,
            wrongAnswer
        };

        // Create Exam Attempt
        Exam_Attempt__c attempt = new Exam_Attempt__c(
            Student_Name__c = 'Anushka',
            Student_Email__c = 'anushka@test.com',
            Start_Time__c = System.now(),
            Status__c = 'In Progress',
            Exam_Config__c = examConfig.Id
        );
        insert attempt;

        // Create Response
        Response__c response = new Response__c(
            Exam_Attempt__c = attempt.Id,
            Question__c = question.Id,
            Answer__c = correctAnswer.Id,
            Is_Selected__c = true
        );
        insert response;
    }

    @IsTest
    static void testCalculateScore() {

        Exam_Attempt__c attempt = [
            SELECT Id
            FROM Exam_Attempt__c
            LIMIT 1
        ];

        Test.startTest();

        Decimal score =
            ResultService.calculateScore(attempt.Id);

        Test.stopTest();

        System.assertEquals(5, score);
    }

    @IsTest
    static void testSubmitExam() {

        Exam_Attempt__c attempt = [
            SELECT Id
            FROM Exam_Attempt__c
            LIMIT 1
        ];

        Test.startTest();

        ResultService.submitExam(attempt.Id);

        Test.stopTest();

        Exam_Attempt__c updatedAttempt = [
            SELECT Score__c,
                   Status__c,
                   End_Time__c
            FROM Exam_Attempt__c
            WHERE Id = :attempt.Id
        ];

        System.assertEquals(5, updatedAttempt.Score__c);
        System.assertEquals('Completed', updatedAttempt.Status__c);
        System.assertNotEquals(null, updatedAttempt.End_Time__c);
    }

}