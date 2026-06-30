@IsTest
private class ExamServiceTest {

    @TestSetup
    static void setupData() {

        Exam_Config__c examConfig = new Exam_Config__c(
            Name = 'Mock Exam',
            Duration_Minutes__c = 60,
            Number_of_Questions__c = 2,
            Passing_Percentage__c = 50,
            Active__c = true
        );
        insert examConfig;

        Question__c q1 = new Question__c(
            Question_Text__c = 'What is Salesforce?',
            Question_Type__c = 'Single Choice',
            Marks__c = 5,
            Active__c = true
        );
        insert q1;

        Question__c q2 = new Question__c(
            Question_Text__c = 'Select CRM Platforms',
            Question_Type__c = 'Multiple Choice',
            Marks__c = 5,
            Active__c = true
        );
        insert q2;

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
    static void testStartExam() {

        Test.startTest();

        Id attemptId = ExamService.startExam(
            'Anushka',
            'anushka@test.com'
        );

        Test.stopTest();

        System.assertNotEquals(null, attemptId);

        Exam_Attempt__c attempt = [
            SELECT Student_Name__c,
                   Student_Email__c,
                   Status__c
            FROM Exam_Attempt__c
            WHERE Id = :attemptId
        ];

        System.assertEquals('Anushka', attempt.Student_Name__c);
        System.assertEquals('anushka@test.com', attempt.Student_Email__c);
        System.assertEquals('In Progress', attempt.Status__c);
    }

    @IsTest
    static void testGetExamAttempt() {

        Id attemptId = ExamService.startExam(
            'Student',
            'student@test.com'
        );

        Test.startTest();

        Exam_Attempt__c attempt =
            ExamService.getExamAttempt(attemptId);

        Test.stopTest();

        System.assertEquals('Student', attempt.Student_Name__c);
    }

    @IsTest
    static void testGetActiveExamConfig() {

        Test.startTest();

        Exam_Config__c config =
            ExamService.getActiveExamConfig();

        Test.stopTest();

        System.assertNotEquals(null, config);
        System.assertEquals(true, config.Active__c);
    }

    @IsTest
    static void testValidateExamConfiguration() {

        Test.startTest();

        ExamService.validateExamConfiguration();

        Test.stopTest();

        System.assert(true);
    }

}