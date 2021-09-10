import 'dart:convert';

class CodeModel {
  CodeModel({
    this.id,
    this.x0,
    this.y0,
    this.standardization,
    this.standardizationHx,
    this.sector,
    this.sectorHx,
    this.entity,
    this.entityHx,
    this.timeStump,
    this.timeStumpHx,
    this.section,
    this.sectionHx,
    this.item,
    this.itemHx,
    this.quality,
    this.qualityHx,
    this.unit,
    this.unitHx,
    this.validty,
    this.validtyHx,
    this.dataStatus,
    this.hcPart,
    this.image,
  });

  int? id;
  int? x0;
  int? y0;
  int? standardization;
  String? standardizationHx;
  int? sector;
  String? sectorHx;
  int? entity;
  String? entityHx;
  int? timeStump;
  String? timeStumpHx;
  int? section;
  String? sectionHx;
  int? item;
  String? itemHx;
  int? quality;
  String? qualityHx;
  int? unit;
  String? unitHx;
  int? validty;
  String? validtyHx;
  bool? dataStatus;
  String? hcPart;
  String? image;

  factory CodeModel.fromRawJson(String? str) =>
      CodeModel.fromJson(json.decode(str!));

  String? toRawJson() => json.encode(toJson());

  factory CodeModel.fromJson(Map<String?, dynamic> json) => CodeModel(
        id: json["id"] == null ? null : json["id"],
        x0: json["x0"] == null ? null : json["x0"],
        y0: json["y0"] == null ? null : json["y0"],
        standardization:
            json["standardization"] == null ? null : json["standardization"],
        standardizationHx: json["standardizationHX"] == null
            ? null
            : json["standardizationHX"],
        sector: json["sector"] == null ? null : json["sector"],
        sectorHx: json["sectorHX"] == null ? null : json["sectorHX"],
        entity: json["entity"] == null ? null : json["entity"],
        entityHx: json["entityHX"] == null ? null : json["entityHX"],
        timeStump: json["timeStump"] == null ? null : json["timeStump"],
        timeStumpHx: json["timeStumpHX"] == null ? null : json["timeStumpHX"],
        section: json["section"] == null ? null : json["section"],
        sectionHx: json["sectionHX"] == null ? null : json["sectionHX"],
        item: json["item"] == null ? null : json["item"],
        itemHx: json["itemHX"] == null ? null : json["itemHX"],
        quality: json["quality"] == null ? null : json["quality"],
        qualityHx: json["qualityHX"] == null ? null : json["qualityHX"],
        unit: json["unit"] == null ? null : json["unit"],
        unitHx: json["unitHX"] == null ? null : json["unitHX"],
        validty: json["validty"] == null ? null : json["validty"],
        validtyHx: json["validtyHX"] == null ? null : json["validtyHX"],
        dataStatus: json["dataStatus"] == null ? null : json["dataStatus"],
        hcPart: json["hcPart"] == null ? null : json["hcPart"],
        image: json["image"] == null ? null : json["image"],
      );

  Map<String?, dynamic> toJson() => {
        if (x0 != null) "x0": x0,
        if (y0 != null) "y0": y0,
        if (standardization != null) "standardization": standardization,
        if (standardizationHx != null) "standardizationHX": standardizationHx,
        if (sector != null) "sector": sector,
        if (sectorHx != null) "sectorHX": sectorHx,
        if (entity != null) "entity": entity,
        if (entityHx != null) "entityHX": entityHx,
        if (timeStump != null) "timeStump": timeStump,
        if (timeStumpHx != null) "timeStumpHX": timeStumpHx,
        if (section != null) "section": section,
        if (sectionHx != null) "sectionHX": sectionHx,
        if (item != null) "item": item,
        if (itemHx != null) "itemHX": itemHx,
        if (quality != null) "quality": quality,
        if (qualityHx != null) "qualityHX": qualityHx,
        if (unit != null) "unit": unit,
        if (unitHx != null) "unitHX": unitHx,
        if (validty != null) "validty": validty,
        if (validtyHx != null) "validtyHX": validtyHx,
        if (dataStatus != null) "dataStatus": dataStatus,
        if (hcPart != null) "hcPart": hcPart,
      };
}
