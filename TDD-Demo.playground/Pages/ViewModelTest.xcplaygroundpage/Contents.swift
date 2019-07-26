import XCTest

//MARK: the production code
public class User {
    var id: String = ""
    var name: String = ""
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public protocol LoginService {
    func login(username: String, password: String) throws -> User
}

public enum LoginError: Error {
    case invalidUserName, invalidPassword
}

public class LoginServiceImpl: LoginService {
    public func login(username: String, password: String) throws -> User {
        if username == "real@gmail.com" {
            throw LoginError.invalidUserName
        }
        
        if password == "realpass" {
            throw LoginError.invalidPassword
        }
        
        return User(id: "1111", name: "Real Name")
    }
}

class ViewModel {
    var email = ""
    var password = ""
    var loginService: LoginService
    var isLogin = false
    var loginError: LoginError?
    
    var isValidEmail: Bool {
        let regexEmail = try! NSRegularExpression(pattern: "^[a-z0-9\\._+-]{8,64}@[a-z]+\\.[gmail|pycogroup]$", options: [])
        return regexEmail.numberOfMatches(in: email, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange(location: 0, length: email.count)) > 0
    }
    
    init(loginService: LoginService) {
        self.loginService = loginService
    }
    
    func login() {
        do {
            try loginService.login(username: email, password: password)
        } catch LoginError.invalidUserName {
            loginError = LoginError.invalidUserName
        } catch {
            loginError = LoginError.invalidPassword
        }
    }
}

//MARK: the unit test code
/*
 * Feature: Login with username and password
 *
 *  I want to login with email and password
 *
 *  Scenario: Email is invalid
 *      Given I input wrong email
 *      When I check whether it is a valid email
 *      Then I should be received false
 *
 *  Scenario: Login success
 *      Given I input email and password correctly
 *      When I press a button login
 *      Then I should not be received any error
 *
 */

/*
 * TDD process
 * 1. Red: write test first (Failed 100%)
 * 2. Green: write production code to make test pass
 * 3. Refactor: apple best practice
 */

/* Objects in an Unit Test
 * sut: System under test (use external services or third-party. Ex: LoginService)
 * di: Dependency injection
 * fake: implement external services or third-party (Ex: FakeLoginServiceImpl)
 */

/*Structure of a unit test
 * 1. Setup
 * 2. Prepare an input
 * 3. Call a method
 * 4. Check the
 * 5. Tear down
 */

class FakeLoginServiceImpl: LoginService {
    func login(username: String, password: String) throws -> User {
        if username == "fake@gmail.com" {
            throw LoginError.invalidUserName
        }
        
        if password == "fakepass" {
            throw LoginError.invalidPassword
        }
        
        return User(id: "0000", name: "Fake Name")
    }
}

class ViewModelTest {
    var sut: ViewModel!
    var di: LoginService! // Dependency Injection
    
    func setup() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        di = FakeLoginServiceImpl()
        sut = ViewModel(loginService: di)
    }
    
    func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        di = nil
    }
    
    func testInvalidEmail() {
        //Given: prepare an input
        sut.email = "test@mailinator.com"
        
        // When: call a method
        let actualValue = sut.isValidEmail
        let expectedValue = false
        
        // Then: check the output
        XCTAssertEqual(actualValue, expectedValue)
    }

    func testLoginSuccess() {
        //Given: prepare an input
        sut.email = "test@gmail.com"
        
        // When: call a method
        sut.login()
        
        // Then: check the output
        XCTAssertNil(sut.loginError)
    }
    
    func testLoginInvalidUserName() {
        //Given: prepare an input
        sut.email = "fake@gmail.com"
        sut.password = "realpass"
        
        // When: call a method
        sut.login()
        let expectedValue = LoginError.invalidUserName
        
        // Then: check the output
        XCTAssertEqual(sut.loginError!, expectedValue)
    }
    
    func testLoginInvalidPassword() {
        //Given: prepare an input
        sut.email = "real@gmail.com"
        sut.password = "fakepass"
        
        // When: call a method
        sut.login()
        let expectedValue = LoginError.invalidPassword
        
        // Then: check the output
        XCTAssertEqual(sut.loginError!, expectedValue)
    }
}

/*
 * We have 4 test cases
 * 1. testCaseInvalidEmail
 * 2. testCaseLoginSuccess
 * 3. testCaseLoginInvalidUserName
 * 4. testCaseLoginInvalidPassword
 */
func logRunningTestCaseName(_ name: String) {
    print("### \(name): Running... ")
}

func logPassedTestCaseName(_ name: String) {
    print("### \(name): Passed \n")
}

let viewModelTest = ViewModelTest()
func testCaseInvalidEmail() {
    logRunningTestCaseName("testCaseInvalidEmail")
    viewModelTest.setup()
    viewModelTest.testInvalidEmail()
    viewModelTest.tearDown()
    logPassedTestCaseName("testCaseInvalidEmail")
}

func testCaseLoginSuccess() {
    logRunningTestCaseName("testCaseLoginSuccess")
    viewModelTest.setup()
    viewModelTest.testLoginSuccess()
    viewModelTest.tearDown()
    logPassedTestCaseName("testCaseLoginSuccess")
}

func testCaseLoginInvalidUserName() {
    logRunningTestCaseName("testCaseLoginInvalidUserName")
    viewModelTest.setup()
    viewModelTest.testLoginInvalidUserName()
    viewModelTest.tearDown()
    logPassedTestCaseName("testCaseLoginInvalidUserName")
}

func testCaseLoginInvalidPassword() {
    logRunningTestCaseName("testCaseLoginInvalidPassword")
    viewModelTest.setup()
    viewModelTest.testLoginInvalidPassword()
    viewModelTest.tearDown()
    logPassedTestCaseName("testCaseLoginInvalidPassword")
}

// Run test cases
testCaseInvalidEmail()
testCaseLoginSuccess()
testCaseLoginInvalidUserName()
testCaseLoginInvalidPassword()
