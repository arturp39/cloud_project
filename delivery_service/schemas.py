from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class DeliveryCreate(BaseModel):
    order_id: int
    courier_name: str

class DeliveryResponse(BaseModel):
    id: int
    order_id: int
    courier_name: str
    status: str 
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
