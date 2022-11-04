module VendorPreview.utils
import VendorPreview.config.VirtualAtelierConfig

// Darkcopse itemParts fix
@wrapMethod(InventoryDataManagerV2)
private final func GetPartInventoryItemData(owner: wref<GameObject>, itemId: ItemID, innerItemData: InnerItemData, opt itemData: wref<gameItemData>, opt record: wref<Item_Record>) -> InventoryItemData {
  if !(ItemID.IsValid(itemId)) && itemData.isVirtualItem {
    itemId = itemData.GetID();
  };
  return wrappedMethod(owner, itemId, innerItemData, itemData);
}

@addMethod(PlayerPuppet)
private final func ScaleAtelierItem(itemData: ref<gameItemData>, quality: CName) -> Void {
  let statsSystem: ref<StatsSystem> = GameInstance.GetStatsSystem(this.GetGame());
  let powerLevelPlayer: Float = statsSystem.GetStatValue(Cast<StatsObjectID>(this.GetEntityID()), gamedataStatType.PowerLevel);
  let powerLevelMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.PowerLevel, gameStatModifierType.Additive, powerLevelPlayer);
  let qualityMod: ref<gameStatModifierData> = RPGManager.CreateStatModifier(gamedataStatType.Quality, gameStatModifierType.Additive, RPGManager.ItemQualityNameToValue(quality));
  statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.PowerLevel, true);
  statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), powerLevelMod);
  statsSystem.RemoveAllModifiers(itemData.GetStatsObjectID(), gamedataStatType.Quality);
  statsSystem.AddSavedModifier(itemData.GetStatsObjectID(), qualityMod);
  RPGManager.ForceItemQuality(this, itemData, quality);
}

public func IsItemClothing(itemID: ItemID) -> Bool {
  return Equals(RPGManager.GetItemCategory(itemID), gamedataItemCategory.Clothing);
}

public func IsItemWeapon(itemID: ItemID) -> Bool {
  return Equals(RPGManager.GetItemCategory(itemID), gamedataItemCategory.Weapon);
}

public func GetZoomArea(equipmentArea: gamedataEquipmentArea) -> InventoryPaperdollZoomArea {
  switch equipmentArea {
    case gamedataEquipmentArea.Weapon:
      return InventoryPaperdollZoomArea.Weapon;
    case gamedataEquipmentArea.Legs:
      return InventoryPaperdollZoomArea.Legs;
    case gamedataEquipmentArea.Feet:
      return InventoryPaperdollZoomArea.Feet;
    case gamedataEquipmentArea.ArmsCW:
    case gamedataEquipmentArea.HandsCW:
    case gamedataEquipmentArea.SystemReplacementCW:
      return InventoryPaperdollZoomArea.Cyberware;
    case gamedataEquipmentArea.QuickSlot:
      return InventoryPaperdollZoomArea.QuickSlot;
    case gamedataEquipmentArea.Consumable:
      return InventoryPaperdollZoomArea.Consumable;
    case gamedataEquipmentArea.Outfit:
      return InventoryPaperdollZoomArea.Outfit;
    case gamedataEquipmentArea.Head:
      return InventoryPaperdollZoomArea.Head;
    case gamedataEquipmentArea.Face:
      return InventoryPaperdollZoomArea.Face;
    case gamedataEquipmentArea.InnerChest:
     return InventoryPaperdollZoomArea.InnerChest;
    case gamedataEquipmentArea.OuterChest:
      return InventoryPaperdollZoomArea.OuterChest;
  };

  return InventoryPaperdollZoomArea.Default;
}

public class StoreGoods extends IScriptable {
  let key: Uint64;
  let item: String;
  let stores: array<String>;

  public func StoreShopIfNotContains(store: String) {
    if !ArrayContains(this.stores, store) {
      ArrayPush(this.stores, store);
    };
  };
}

public func CheckDuplicates(stores: array<ref<VirtualShop>>, controller: ref<WebPage>) -> Void {
  if VirtualAtelierConfig.DisableDuplicatesChecker() {
    return ;
  };
  
  let itemsHashMap: ref<inkHashMap> = new inkHashMap();
  let storeIndex: Int32 = 0;
  let store: ref<VirtualShop>;
  let storeGoodie: ref<StoreGoods>;
  let items: array<String>;
  let item: String;
  let key: Uint64;
  let itemIndex: Int32;

  // Populate items map
  while storeIndex < ArraySize(stores) {
    store = stores[storeIndex];
    items = store.items;
    itemIndex = 0;
    while itemIndex < ArraySize(items) {
      item = items[itemIndex];
      key = TDBID.ToNumber(TDBID.Create(item));

      if itemsHashMap.KeyExist(key) {
        // Extract, add store and save
        storeGoodie = itemsHashMap.Get(key) as StoreGoods;
        storeGoodie.StoreShopIfNotContains(store.storeName);
        itemsHashMap.Set(key, storeGoodie);
      } else {
        // Insert new
        storeGoodie = new StoreGoods();
        storeGoodie.key = key;
        storeGoodie.item = item;
        storeGoodie.StoreShopIfNotContains(store.storeName);
        itemsHashMap.Insert(key, storeGoodie);
      };

      itemIndex += 1;
    };
    storeIndex += 1;
  };

  // Find items with more than single store
  let mapValues: array<wref<IScriptable>>;
  let storedItem: ref<StoreGoods>;
  let hasDuplicates: Bool = false;
  let duplicatesInfo: String = "";
  let mapItemIndex: Int32 = 0;
  let isLast: Bool = false;
  let storeIndex: Int32;
  
  itemsHashMap.GetValues(mapValues);
  while mapItemIndex < ArraySize(mapValues) {
    storedItem = mapValues[mapItemIndex] as StoreGoods;
    if IsDefined(storedItem) && ArraySize(storedItem.stores) > 1 {
      hasDuplicates = true;
      duplicatesInfo = s"[DUPLICATE ITEM: \(storedItem.item)]" + ": ";
      storeIndex = 0;
      while storeIndex < ArraySize(storedItem.stores) {
        isLast = Equals(storeIndex, ArraySize(storedItem.stores) - 1);
        if isLast {
          duplicatesInfo += s"\(storedItem.stores[storeIndex])";
        } else {
          duplicatesInfo += s"\(storedItem.stores[storeIndex]), ";
        };
        storeIndex += 1;
      };

      duplicatesInfo += " ]";
      AtelierLog(duplicatesInfo);
    };

    mapItemIndex += 1;
  };

  if hasDuplicates {
    controller.DisplayWarning(VirtualAtelierText.Warning());
  };
}

public func AtelierLog(str: String) -> Void {
  LogChannel(n"DEBUG", s"Atelier: \(str)");
}

public func AtelierDebug(str: String) -> Void {
  // LogChannel(n"DEBUG", s"Atelier DEBUG: \(str)");
}
