from arguments import args
from fastapi import FastAPI, HTTPException, APIRouter
from fastapi.routing import APIRoute
from fastapi.openapi.utils import get_openapi
from starlette.middleware.cors import CORSMiddleware
from haystack import __version__ as haystack_version

from pipelines import setup_pipelines

app = None
pipelines = None

from fastapi import HTTPException
from starlette.requests import Request
from starlette.responses import JSONResponse


async def http_error_handler(_: Request, exc: HTTPException) -> JSONResponse:
    return JSONResponse({"errors": [exc.detail]}, status_code=exc.status_code)

def get_app() -> FastAPI:
    """
    Initializes the App object and creates the global pipelines as possible.
    """
    global app  # pylint: disable=global-statement
    if app:
        return app

    from rest_api.config import ROOT_PATH

    app = FastAPI(
        title="Haystack REST API",
        debug=True,
        version=haystack_version,
        root_path=ROOT_PATH,
    )

    # Creates the router for the API calls
    from controller import  search

    router = APIRouter()
    router.include_router(search.router, tags=["search"])


    # This middleware enables allow all cross-domain requests to the API from a browser. For production
    # deployments, it could be made more restrictive.
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_exception_handler(HTTPException, http_error_handler)
    app.include_router(router)

    # Simplify operation IDs so that generated API clients have simpler function
    # names (see https://fastapi.tiangolo.com/advanced/path-operation-advanced-configuration/#using-the-path-operation-function-name-as-the-operationid).
    # The operation IDs will be the same as the route names (i.e. the python method names of the endpoints)
    # Should be called only after all routes have been added.
    for route in app.routes:
        if isinstance(route, APIRoute):
            route.operation_id = route.name

    return app


def get_pipelines():
    global pipelines  # pylint: disable=global-statement
    if not pipelines:
        pipelines = setup_pipelines(args)
    return pipelines
