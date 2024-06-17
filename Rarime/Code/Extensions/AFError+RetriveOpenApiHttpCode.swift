import Foundation
import Alamofire

extension AFError {
    func retriveOpenApiHttpCode() throws -> String {
        guard case .responseValidationFailed(let errorReason) = self else {
            throw self
        }
        
        guard case .customValidationFailed(let validationError) = errorReason else {
            throw self
        }
        
        guard let localError = validationError as? Errors else {
            throw self
        }
        
        guard case .openAPIErrors(let openApiErrors) = localError else {
            throw self
        }
        
        guard let openApiError = openApiErrors.first else {
            throw self
        }
        
        return openApiError.status
    }
}
