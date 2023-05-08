module VirtualAtelier.Core

public class AtelierTexts {
  // Atelier tab name inside your PC
  public static func Name() -> String = "Atelier"
  // Empty stores screen placeholder
  public static func EmptyPlaceholder() -> String = "No custom stores installed"
  // Previous page button
  public static func PaginationPrev() -> String = "Prev"
  // Next page button
  public static func PaginationNext() -> String = "Next"
  // Used for label "Page 1 of 3"
  public static func PaginationPrefix() -> String = "Page"
  // Used for label "Page 1 of 3"
  public static func PaginationConj() -> String = "of"

  // Preview button hint
  public static func PreviewEnable() -> String = "Enable Preview"
  // Preview button hint
  public static func PreviewDisable() -> String = "Disable Preview"
  // Preview button hint
  public static func PreviewReset() -> String = "Reset Preview"
  // Preview button hint
  public static func PreviewRemoveAllGarment() -> String = "Remove All Garment"
  // Preview button hint
  public static func PreviewRemovePreviewGarment() -> String = "Remove Preview Garment"
  // Preview button hint
  public static func PreviewItem() -> String = "Preview Item"
  // Bookmark hints
  public static func AddToFavorites() -> String = "Add to favorites"
  public static func RemoveFromFavorites() -> String = "Remove from favorites"
}