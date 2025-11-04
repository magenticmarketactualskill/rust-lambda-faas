'''
use serde_json::{json, Value};
use std::collections::HashMap;

/// Lambda invocation context (simplified for example)
#[repr(C)]
#[derive(Debug)]
pub struct LambdaContext {
    pub request_id: String,
    pub deadline_ms: u64,
    pub invoked_function_arn: String,
    pub trace_id: String,
}

/// Example function that processes a JSON payload
#[no_mangle]
pub unsafe extern "C" fn handle(
    payload: &Value,
    _context: &LambdaContext,
) -> Result<Value, String> {
    if let Some(name) = payload.get("name").and_then(|n| n.as_str()) {
        let response = json!({
            "message": format!("Hello, {}!", name),
            "processed": true,
        });
        Ok(response)
    } else {
        Err("Missing 'name' field in payload".to_string())
    }
}

/// Example function that returns an error
#[no_mangle]
pub unsafe extern "C" fn handle_error(
    _payload: &Value,
    _context: &LambdaContext,
) -> Result<Value, String> {
    Err("This is a simulated error from the user function".to_string())
}
'''
