from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

class BaseSchema(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        from_attributes=True
    )

class SendCodeRequest(BaseSchema):
    country_code: str
    phone_number: str

class VerifyCodeRequest(BaseSchema):
    country_code: str
    phone_number: str
    otp: str

class TokenResponse(BaseSchema):
    accessToken: str
    tokenType: str = "bearer"
    success: bool = True

