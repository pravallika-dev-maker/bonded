from pydantic import BaseModel, ConfigDict, field_validator
from pydantic.alias_generators import to_camel
import re

class BaseSchema(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        from_attributes=True
    )

class SendCodeRequest(BaseSchema):
    country_code: str
    phone_number: str

    @field_validator('phone_number')
    @classmethod
    def validate_phone(cls, v: str) -> str:
        cleaned = re.sub(r'[\s\-()]', '', v)
        if not re.match(r'^\+?[1-9]\d{6,14}$', cleaned):
            raise ValueError('Invalid phone number format')
        return cleaned

    @field_validator('country_code')
    @classmethod
    def validate_country_code(cls, v: str) -> str:
        if not re.match(r'^\+?[1-9]\d{0,3}$', v.strip()):
            raise ValueError('Invalid country code')
        return v.strip()

class VerifyCodeRequest(BaseSchema):
    country_code: str
    phone_number: str
    otp: str

    @field_validator('phone_number')
    @classmethod
    def validate_phone(cls, v: str) -> str:
        cleaned = re.sub(r'[\s\-()]', '', v)
        if not re.match(r'^\+?[1-9]\d{6,14}$', cleaned):
            raise ValueError('Invalid phone number format')
        return cleaned

class TokenResponse(BaseSchema):
    accessToken: str
    tokenType: str = "bearer"
    success: bool = True
