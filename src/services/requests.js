import { get, post, put } from './httpClient';

export const getAllRequests = async () => {
  return get('/api/requests');
};

export const getRequestsByEmployee = async (ghrId) => {
  return get(`/api/requests/employee/${ghrId}`);
};

export const getRequestById = async (id) => {
  return get(`/api/requests/${id}`);
};

export const createTravelPreApproval = async (dto) => {
  const payload = {
    subtype: dto.subtype,
    destination: dto.destination,
    purpose: dto.purpose,
    startDate: dto.startDate,
    endDate: dto.endDate,
    travelMode: "Flight", // Default or extract from dto if available
    preApproval: {
      status: "pending",
      hasKnoxApproval: !!dto.knoxApproval,
      knoxApproval: dto.knoxApproval ? dto.knoxApproval[0]?.name : null,
      hasTravelInsurance: !!dto.travelInsurance,
      travelInsurance: dto.travelInsurance ? dto.travelInsurance[0]?.name : null,
      hasVisa: !!dto.visa,
      visa: dto.visa ? dto.visa[0]?.name : null,
      hasPassportCopy: !!dto.passport,
      passportCopy: dto.passport ? dto.passport[0]?.name : null
    }
  };
  return post(`/api/requests/travel/${dto.ghrId}`, payload);
};

export const submitSettlement = async (id, dto) => {
  const payload = {
    hotelAmount: dto.hotelActual,
    boardingPass: dto.documents?.settlement?.length > 0 ? dto.documents.settlement[0].name : null,
    hasBoardingPass: !!(dto.documents?.settlement?.length > 0),
    localConveyances: dto.conveyanceActual > 0 ? [{ conveyanceType: 'Taxi', amount: dto.conveyanceActual }] : [],
    winterClothesAmount: dto.winterClothesActual,
    winterClothes: dto.winterClothesActual > 0
  };
  return post(`/api/requests/${id}/settlement`, payload);
};

export const createInternetRequest = async (dto) => {
  const payload = {
    provider: dto.provider,
    frequency: "Monthly",
    periods: dto.months.map(m => ({ periodLabel: m.month, amount: m.amount }))
  };
  return post(`/api/requests/internet/${dto.ghrId}`, payload);
};

export const createCarpoolRequest = async (dto) => {
  const payload = {
    vehicleOwnerEmpId: dto.ghrId,
    vehicleNumber: dto.vehicleNumber,
    totalMembers: dto.members?.length || 0,
    members: dto.members?.map(m => ({
      empId: m.ghrId,
      employeeType: "Full-Time",
      pickupAddress: m.pickupLocation || "Unknown",
      metroDistanceKm: 0 // Mock distance for now
    })) || []
  };
  return post('/api/requests/carpool', payload);
};

export const createRelocationRequest = async (dto) => {
  const payload = {
    fromCity: dto.fromCity,
    toCity: dto.toCity,
    relocDate: dto.relocationDate,
    expenses: Object.entries(dto.components).map(([key, val]) => ({
      category: key,
      amount: val,
      hasBillDocument: false
    }))
  };
  return post(`/api/requests/relocation/${dto.ghrId}`, payload);
};

export const saveDraftRequest = async (dto) => {
  // Not fully supported in the backend yet, just pass through to create for now
  if (dto.type === 'travel') return createTravelPreApproval(dto);
  throw new Error("Drafts not implemented in backend yet");
};

export const extendTrip = async (id, dto) => {
  const payload = {
    revisedEndDate: dto.endDate,
    reason: dto.reason,
    hasApprovalDocument: !!dto.approvalDoc,
    approvalDocument: dto.approvalDoc ? dto.approvalDoc[0]?.name : null
  };
  return post(`/api/requests/${id}/extend-trip`, payload);
};

export const financeReview = async (id, { action, financeNote, type, stage }) => {
  const payload = {
    financeEmpId: "admin", // To be filled by backend context ideally
    financeNote,
    stage: stage,
    status: action,
    preApprovalStatus: stage === 'pre-approval' ? action : null,
    settlementStatus: stage === 'settlement' ? action : null,
    extensionStatus: stage === 'extension-pending' ? action : null
  };
  
  await put(`/api/requests/${id}/finance-review`, payload);
  return getRequestById(id);
};
