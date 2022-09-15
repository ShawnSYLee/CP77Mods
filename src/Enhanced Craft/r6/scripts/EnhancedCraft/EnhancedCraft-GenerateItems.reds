import EnhancedCraft.Common.L

public class EnhancedCraftItemsGenerator extends ScriptableTweak {

  protected cb func OnApply() -> Void {
    let weaponsVariants: array<CName>;
    let clothesVariants: array<CName>;
    let id: TweakDBID;
    let name: String;
    L("Checking weapon items...");
    for record in TweakDBInterface.GetRecords(n"WeaponItem") {
      let item = record as Item_Record;
      id = item.GetID();
      name = TweakDBInterface.GetString(id + t".stringName", "");
      weaponsVariants = TweakDBInterface.GetCNameArray(id + t".weaponVariants");
      if ArraySize(weaponsVariants) > 0 {
        this.GenerateNewWeaponItem(name, item, weaponsVariants);
      };
    };
    L("Checking clothes items...");
    for record in TweakDBInterface.GetRecords(n"Clothing") {
      let item = record as Item_Record;
      id = item.GetID();
      name = TweakDBInterface.GetString(id + t".stringName", "");
      clothesVariants = TweakDBInterface.GetCNameArray(id + t".clothesVariants");
      if ArraySize(clothesVariants) > 0 {
        this.GenerateClothesVariants(name, item, clothesVariants);
      };
    };
  }

  private func GenerateNewWeaponItem(baseName: String, baseRecord: ref<Item_Record>, variants: array<CName>) -> Void {
    let baseRecordId: TweakDBID = baseRecord.GetID();
    let variantRecord: ref<Item_Record>;
    let variantVisualTags: array<CName>;
    let firstTag: CName;
    let newRecordId: TweakDBID;
    let newRecordIdStr: String;
    let newRecordIdStrName: CName;
    let craftingVariants: array<TweakDBID>;
    let isPresetIconic: Bool;

    L(s"Generating variants for: \(TDBID.ToStringDEBUG(baseRecordId)) - \(baseName)");

    for variant in variants {
      variantRecord = TweakDBInterface.GetItemRecord(TDBID.Create(NameToString(variant)));
      variantVisualTags = variantRecord.VisualTags();
      isPresetIconic = TweakDBInterface.GetBool(TDBID.Create(s"\(variant).iconicVariant"), false);

      // -- GENERATE VISUAL TAG VARIANT
      if ArraySize(variantVisualTags) > 0 {
        firstTag = variantVisualTags[0];
        newRecordIdStr = s"\(baseName)_\(firstTag)";
        newRecordIdStrName = StringToName(newRecordIdStr);
        newRecordId = TDBID.Create(newRecordIdStr);
        TweakDBManager.CloneRecord(newRecordIdStrName, baseRecordId);
        // Set flats
        TweakDBManager.SetFlat(newRecordIdStrName + n".isPresetIconic", isPresetIconic);
        TweakDBManager.SetFlat(newRecordIdStrName + n".usesVariants", true);
        TweakDBManager.SetFlat(newRecordIdStrName + n".visualTags", variantVisualTags);
        TweakDBManager.UpdateRecord(newRecordId);
        ArrayPush(craftingVariants, newRecordId);
        L(s" - generated - \(firstTag) variant for \(GetLocalizedTextByKey(baseRecord.DisplayName())): type \(baseRecord.Quality().Type()), iconic: \(isPresetIconic) -> \(newRecordIdStrName)");
      };
    };

    if ArraySize(craftingVariants) > 0 {
      TweakDBManager.SetFlat(baseRecordId + t".ecraftVariants", ToVariant(craftingVariants));
    };
  }

  private func GenerateClothesVariants(baseName: String, baseRecord: ref<Item_Record>, variants: array<CName>) -> Void {
    let baseRecordId: TweakDBID = baseRecord.GetID();
    let variantRecord: ref<Item_Record>;
    let variantAppearanceName: CName;
    let newRecordId: TweakDBID;
    let newRecordIdStr: String;
    let newRecordIdStrName: CName;
    let craftingVariants: array<TweakDBID>;
    let isPresetIconic: Bool;

    L(s"Generating variants for: \(TDBID.ToStringDEBUG(baseRecordId)) - \(baseName)");

    for variant in variants {
      variantRecord = TweakDBInterface.GetItemRecord(TDBID.Create(NameToString(variant)));
      variantAppearanceName = variantRecord.AppearanceName();

      if NotEquals(variantAppearanceName, n"") {
        newRecordIdStr = StrBeforeLast(s"\(baseName)_\(variantAppearanceName)", "_");
        newRecordIdStrName = StringToName(newRecordIdStr);
        newRecordId = TDBID.Create(newRecordIdStr);
        TweakDBManager.CloneRecord(newRecordIdStrName, baseRecordId);
        // Set flats
        let displayName: Variant = TweakDBInterface.GetFlat(variantRecord.GetID() + t".displayName");
        let localizedDescription: Variant = TweakDBInterface.GetFlat(variantRecord.GetID() + t".localizedDescription");
        let tags: Variant = TweakDBInterface.GetFlat(variantRecord.GetID() + t".tags");
        TweakDBManager.SetFlat(newRecordIdStrName + n".appearanceName", variantAppearanceName);
        TweakDBManager.SetFlat(newRecordIdStrName + n".displayName", displayName);
        TweakDBManager.SetFlat(newRecordIdStrName + n".localizedDescription", localizedDescription);
        TweakDBManager.SetFlat(newRecordIdStrName + n".iconPath", variantRecord.IconPath());
        TweakDBManager.SetFlat(newRecordIdStrName + n".tags", tags);
        TweakDBManager.UpdateRecord(newRecordId);
        L(s" - generated - \(variantAppearanceName) variant for \(GetLocalizedTextByKey(baseRecord.DisplayName())): type \(baseRecord.Quality().Type()), iconic: \(isPresetIconic) -> \(newRecordIdStrName)");
        ArrayPush(craftingVariants, newRecordId);
      };
    };

    if ArraySize(craftingVariants) > 0 {
      TweakDBManager.SetFlat(baseRecordId + t".ecraftVariants", ToVariant(craftingVariants));
    };
  }
}
