use lambda_http::{service_fn, Body, Error, Request, Response};

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_http::run(service_fn(handler)).await
}

async fn handler(_: Request) -> Result<Response<Body>, Error> {
    Ok(Response::new(Body::from("Heeeey!")))
}
