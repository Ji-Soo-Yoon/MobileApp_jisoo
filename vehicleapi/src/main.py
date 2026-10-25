from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Vehicle Manufacturer API")

# In-memory databases
manufacturers = {}
vehicles = {}


# =========================
# Models
# =========================

class Manufacturer(BaseModel):
    id: int
    name: str
    country: str


class Vehicle(BaseModel):
    id: int
    manufacturer_id: int
    model: str
    year: int


# =========================
# Manufacturer CRUD
# =========================

@app.post("/manufacturers")
def create_manufacturer(manufacturer: Manufacturer):
    if manufacturer.id in manufacturers:
        raise HTTPException(
            status_code=400,
            detail="Manufacturer already exists"
        )

    manufacturers[manufacturer.id] = manufacturer
    return manufacturer


@app.get("/manufacturers")
def get_all_manufacturers():
    return list(manufacturers.values())


@app.get("/manufacturers/{manufacturer_id}")
def get_manufacturer(manufacturer_id: int):
    if manufacturer_id not in manufacturers:
        raise HTTPException(
            status_code=404,
            detail="Manufacturer not found"
        )

    return manufacturers[manufacturer_id]


@app.put("/manufacturers/{manufacturer_id}")
def update_manufacturer(
        manufacturer_id: int,
        manufacturer: Manufacturer):

    if manufacturer_id not in manufacturers:
        raise HTTPException(
            status_code=404,
            detail="Manufacturer not found"
        )

    manufacturers[manufacturer_id] = manufacturer
    return manufacturer


@app.delete("/manufacturers/{manufacturer_id}")
def delete_manufacturer(manufacturer_id: int):

    if manufacturer_id not in manufacturers:
        raise HTTPException(
            status_code=404,
            detail="Manufacturer not found"
        )

    deleted_manufacturer = manufacturers.pop(manufacturer_id)

    # Delete related vehicles
    vehicle_ids_to_remove = [
        vehicle_id
        for vehicle_id, vehicle in vehicles.items()
        if vehicle.manufacturer_id == manufacturer_id
    ]

    for vehicle_id in vehicle_ids_to_remove:
        vehicles.pop(vehicle_id)

    return {
        "message": "Manufacturer deleted successfully",
        "manufacturer": deleted_manufacturer
    }


# =========================
# Vehicle CRUD
# =========================

@app.post("/vehicles")
def create_vehicle(vehicle: Vehicle):

    if vehicle.id in vehicles:
        raise HTTPException(
            status_code=400,
            detail="Vehicle already exists"
        )

    if vehicle.manufacturer_id not in manufacturers:
        raise HTTPException(
            status_code=404,
            detail="Manufacturer does not exist"
        )

    vehicles[vehicle.id] = vehicle
    return vehicle


@app.get("/vehicles")
def get_all_vehicles():
    return list(vehicles.values())


@app.get("/vehicles/{vehicle_id}")
def get_vehicle(vehicle_id: int):

    if vehicle_id not in vehicles:
        raise HTTPException(
            status_code=404,
            detail="Vehicle not found"
        )

    return vehicles[vehicle_id]


@app.put("/vehicles/{vehicle_id}")
def update_vehicle(
        vehicle_id: int,
        vehicle: Vehicle):

    if vehicle_id not in vehicles:
        raise HTTPException(
            status_code=404,
            detail="Vehicle not found"
        )

    if vehicle.manufacturer_id not in manufacturers:
        raise HTTPException(
            status_code=404,
            detail="Manufacturer does not exist"
        )

    vehicles[vehicle_id] = vehicle
    return vehicle


@app.delete("/vehicles/{vehicle_id}")
def delete_vehicle(vehicle_id: int):

    if vehicle_id not in vehicles:
        raise HTTPException(
            status_code=404,
            detail="Vehicle not found"
        )

    deleted_vehicle = vehicles.pop(vehicle_id)

    return {
        "message": "Vehicle deleted successfully",
        "vehicle": deleted_vehicle
    }